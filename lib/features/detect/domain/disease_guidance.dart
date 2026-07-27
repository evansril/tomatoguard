class DiseaseGuidance {
  const DiseaseGuidance({
    required this.summary,
    required this.causes,
    required this.signs,
    required this.recommendations,
  });

  final String summary;
  final List<String> causes;
  final List<String> signs;
  final List<String> recommendations;
}

abstract final class DiseaseGuidanceCatalog {
  static DiseaseGuidance forClass(String className) {
    return switch (className) {
      'Tomato_Early_Blight' => const DiseaseGuidance(
        summary:
            'Early blight is a common fungal tomato disease. It usually begins '
            'on older, lower leaves and can weaken the plant if it spreads.',
        causes: [
          'The fungus Alternaria solani or closely related Alternaria species.',
          'Warm, humid weather and leaves that remain wet for long periods.',
          'Infected plant debris or soil splashing onto lower leaves.',
          'Plant stress caused by poor nutrition, drought, or crowding.',
        ],
        signs: [
          'Brown spots with circular, target-like rings.',
          'Yellow tissue developing around dark leaf spots.',
          'Damage beginning on older leaves near the soil.',
        ],
        recommendations: [
          'Remove badly affected lower leaves using clean tools.',
          'Water at soil level and avoid wetting the foliage.',
          'Improve airflow by spacing and supporting plants properly.',
          'Add clean mulch to reduce soil splash onto leaves.',
          'Remove infected debris after harvest and rotate away from tomatoes '
              'and potatoes in the affected bed.',
          'If disease continues to spread, ask a local agricultural specialist '
              'about an approved fungicide and follow its label exactly.',
        ],
      ),
      'Tomato_Late_Blight' => const DiseaseGuidance(
        summary:
            'Late blight is a fast-moving disease caused by a water mold. '
            'It can damage leaves, stems, and fruit very quickly in cool, wet weather.',
        causes: [
          'The pathogen Phytophthora infestans.',
          'Cool, damp conditions with prolonged leaf moisture.',
          'Spores carried by wind from infected tomato or potato plants.',
          'Nearby infected plants, volunteer potatoes, or infected tubers.',
        ],
        signs: [
          'Irregular, water-soaked gray-green or brown patches.',
          'Pale or white growth beneath lesions during humid conditions.',
          'Dark stem lesions or firm brown patches on fruit.',
        ],
        recommendations: [
          'Isolate the plant and remove severely affected material promptly.',
          'Do not compost infected plants unless your process reliably destroys pathogens.',
          'Keep foliage dry and increase spacing and ventilation.',
          'Inspect nearby tomato and potato plants every day for new symptoms.',
          'Contact a local extension or crop specialist because outbreaks can spread rapidly.',
          'Use only locally approved treatments and follow the product label.',
        ],
      ),
      'Tomato_Healthy' => const DiseaseGuidance(
        summary:
            'The leaf appears consistent with a healthy tomato plant. Continue '
            'regular care and monitor for changes.',
        causes: [
          'Balanced plant growth with no strong visual disease pattern detected.',
          'Suitable watering, nutrition, light, and airflow.',
        ],
        signs: [
          'Mostly even green color.',
          'No prominent spreading lesions or target-like spots.',
          'Leaf structure appears intact.',
        ],
        recommendations: [
          'Continue watering deeply at soil level when needed.',
          'Maintain good airflow and avoid overcrowding.',
          'Check both sides of leaves regularly for pests or new spots.',
          'Keep tools clean and remove fallen plant debris.',
        ],
      ),
      'Background_without_leaves' => const DiseaseGuidance(
        summary:
            'The model could not find a tomato leaf in this image, so no plant '
            'health assessment was made.',
        causes: [
          'The leaf may be too small, hidden, blurred, or outside the frame.',
          'The background may occupy most of the image.',
        ],
        signs: [
          'No clear single tomato leaf is visible.',
          'The subject is too dark, distant, or obstructed.',
        ],
        recommendations: [
          'Place one leaf near the center of the frame.',
          'Move closer and use bright, even natural light.',
          'Use a simple background and keep the camera steady.',
          'Retake the photo without digital zoom.',
        ],
      ),
      'Unknown_tomato_Disease' => const DiseaseGuidance(
        summary:
            'The leaf may be unhealthy, but its pattern does not closely match '
            'the tomato diseases this model was trained to identify.',
        causes: [
          'Another fungal, bacterial, viral, nutritional, or environmental problem.',
          'Pest damage or several problems occurring together.',
          'An image that does not show enough distinguishing detail.',
        ],
        signs: [
          'Visible damage without a strong early- or late-blight pattern.',
          'Unusual discoloration, distortion, holes, or mixed symptoms.',
        ],
        recommendations: [
          'Photograph both sides of the leaf and inspect the full plant.',
          'Check stems, fruit, soil moisture, and nearby plants for related symptoms.',
          'Keep the plant separate from healthy seedlings if disease is spreading.',
          'Consult a local agricultural extension service or plant specialist.',
          'Avoid applying a treatment until the cause is identified.',
        ],
      ),
      _ => const DiseaseGuidance(
        summary:
            'The image did not produce a reliable match. This result should not '
            'be used as a confirmed diagnosis.',
        causes: [
          'Low image quality, an unsupported plant, or an unfamiliar condition.',
          'Symptoms outside the classes recognized by this model.',
        ],
        signs: [
          'No supported class received a reliable match.',
          'The visible pattern may be incomplete or unclear.',
        ],
        recommendations: [
          'Retake the photo in bright, even light with one leaf centered.',
          'Try a second leaf from the same plant.',
          'Consult a plant specialist if symptoms continue or spread.',
          'Avoid treatment based only on an uncertain result.',
        ],
      ),
    };
  }
}
