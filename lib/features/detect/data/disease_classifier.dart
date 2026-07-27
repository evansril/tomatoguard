import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class ClassificationResult {
  const ClassificationResult({
    required this.className,
    required this.displayName,
    required this.confidence,
    required this.status,
    required this.scores,
  });

  final String className;
  final String displayName;
  final double confidence;
  final DetectionStatus status;
  final Map<String, double> scores;
}

enum DetectionStatus { healthy, diseased, uncertain, noLeaf }

class DiseaseClassifier {
  Interpreter? _interpreter;
  List<String> _labels = const [];

  Future<void> load() async {
    if (_interpreter != null) return;

    final labelsText = await rootBundle.loadString('assets/class_names.txt');
    _labels = labelsText
        .split(RegExp(r'\r?\n'))
        .map((label) => label.trim())
        .where((label) => label.isNotEmpty)
        .toList(growable: false);
    _interpreter = await Interpreter.fromAsset('assets/se_model.tflite');

    final outputCount = _interpreter!.getOutputTensor(0).shape.last;
    if (outputCount != _labels.length) {
      close();
      throw StateError(
        'The model returns $outputCount classes, but '
        '${_labels.length} labels were provided.',
      );
    }
  }

  Future<ClassificationResult> classify(Uint8List bytes) async {
    await load();
    final interpreter = _interpreter!;
    final inputTensor = interpreter.getInputTensor(0);
    final outputTensor = interpreter.getOutputTensor(0);
    final shape = inputTensor.shape;

    if (shape.length != 4 || shape.first != 1 || shape.last != 3) {
      throw UnsupportedError('Unsupported model input shape: $shape');
    }

    var source = img.decodeImage(bytes);
    if (source == null) {
      throw const FormatException('The selected file is not a valid image.');
    }
    source = img.bakeOrientation(source);

    final height = shape[1];
    final width = shape[2];
    final resized = img.copyResize(
      source,
      width: width,
      height: height,
      interpolation: img.Interpolation.linear,
    );

    final input = _buildInput(resized, inputTensor.type, shape);
    final output = _emptyOutput(outputTensor.type, outputTensor.shape);
    interpreter.run(input, output);

    var scores = _flattenNumbers(output);
    if (outputTensor.type == TensorType.uint8 ||
        outputTensor.type == TensorType.int8) {
      final params = outputTensor.params;
      scores = scores
          .map((value) => (value - params.zeroPoint) * params.scale)
          .toList(growable: false);
    }
    scores = _asProbabilities(scores);

    var bestIndex = 0;
    for (var index = 1; index < scores.length; index++) {
      if (scores[index] > scores[bestIndex]) bestIndex = index;
    }

    final className = _labels[bestIndex];
    final confidence = scores[bestIndex];
    return ClassificationResult(
      className: className,
      displayName: _displayName(className),
      confidence: confidence,
      status: confidence < 0.60
          ? DetectionStatus.uncertain
          : _statusFor(className),
      scores: {
        for (var index = 0; index < _labels.length; index++)
          _labels[index]: scores[index],
      },
    );
  }

  Object _buildInput(img.Image image, TensorType type, List<int> shape) {
    if (type == TensorType.float32) {
      final pixels = List<double>.filled(image.width * image.height * 3, 0);
      var offset = 0;
      for (var y = 0; y < image.height; y++) {
        for (var x = 0; x < image.width; x++) {
          final pixel = image.getPixel(x, y);
          pixels[offset++] = pixel.r / 255.0;
          pixels[offset++] = pixel.g / 255.0;
          pixels[offset++] = pixel.b / 255.0;
        }
      }
      return pixels.reshape<double>(shape);
    }

    if (type == TensorType.uint8 || type == TensorType.int8) {
      final params = _interpreter!.getInputTensor(0).params;
      final pixels = List<int>.filled(image.width * image.height * 3, 0);
      var offset = 0;
      for (var y = 0; y < image.height; y++) {
        for (var x = 0; x < image.width; x++) {
          final pixel = image.getPixel(x, y);
          for (final channel in [pixel.r, pixel.g, pixel.b]) {
            final normalized = channel / 255.0;
            pixels[offset++] = params.scale == 0
                ? channel.toInt()
                : (normalized / params.scale + params.zeroPoint).round();
          }
        }
      }
      return pixels.reshape<int>(shape);
    }

    throw UnsupportedError('Unsupported model input type: $type');
  }

  Object _emptyOutput(TensorType type, List<int> shape) {
    final length = shape.fold<int>(1, (total, dimension) => total * dimension);
    if (type == TensorType.float32) {
      return List<double>.filled(length, 0).reshape<double>(shape);
    }
    if (type == TensorType.uint8 || type == TensorType.int8) {
      return List<int>.filled(length, 0).reshape<int>(shape);
    }
    throw UnsupportedError('Unsupported model output type: $type');
  }

  List<double> _flattenNumbers(Object value) {
    final result = <double>[];

    void visit(Object? item) {
      if (item is List) {
        for (final child in item) {
          visit(child);
        }
      } else if (item is num) {
        result.add(item.toDouble());
      }
    }

    visit(value);
    return result;
  }

  List<double> _asProbabilities(List<double> values) {
    final sum = values.fold<double>(0, (total, value) => total + value);
    final alreadyProbabilities =
        values.every((value) => value >= 0 && value <= 1) &&
        (sum - 1).abs() < 0.05;
    if (alreadyProbabilities) return values;

    final maximum = values.reduce((first, second) {
      return math.max(first, second).toDouble();
    });
    final exponentials = values
        .map((value) => math.exp(value - maximum))
        .toList(growable: false);
    final exponentialSum = exponentials.fold<double>(
      0,
      (total, value) => total + value,
    );
    return exponentials
        .map((value) => value / exponentialSum)
        .toList(growable: false);
  }

  String _displayName(String value) {
    const names = {
      'Background_without_leaves': 'No tomato leaf detected',
      'Tomato_Early_Blight': 'Tomato Early Blight',
      'Tomato_Healthy': 'Healthy Tomato Leaf',
      'Tomato_Late_Blight': 'Tomato Late Blight',
      'Unknown': 'Unknown',
      'Unknown_tomato_Disease': 'Unknown Tomato Disease',
    };
    return names[value] ?? value.replaceAll('_', ' ');
  }

  DetectionStatus _statusFor(String value) {
    if (value == 'Tomato_Healthy') return DetectionStatus.healthy;
    if (value == 'Tomato_Early_Blight' || value == 'Tomato_Late_Blight') {
      return DetectionStatus.diseased;
    }
    if (value == 'Background_without_leaves') {
      return DetectionStatus.noLeaf;
    }
    return DetectionStatus.uncertain;
  }

  void close() {
    _interpreter?.close();
    _interpreter = null;
  }
}
