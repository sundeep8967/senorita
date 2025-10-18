import 'package:flutter/material.dart';
import '../services/date_selection_service.dart';

class RatingDialog extends StatefulWidget {
  final String chatRoomId;
  final String raterId;
  final String ratedUserId;
  final String ratedUserName;
  final DateTime meetupDate;

  const RatingDialog({
    Key? key,
    required this.chatRoomId,
    required this.raterId,
    required this.ratedUserId,
    required this.ratedUserName,
    required this.meetupDate,
  }) : super(key: key);

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  final DateSelectionService _service = DateSelectionService();
  final TextEditingController _commentController = TextEditingController();

  int _respectfulnessRating = 5;
  int _punctualityRating = 5;
  int _conversationRating = 5;
  int _overallRating = 5;
  bool _showedUp = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      await _service.submitMeetupRating(
        chatRoomId: widget.chatRoomId,
        raterId: widget.raterId,
        ratedUserId: widget.ratedUserId,
        meetupDate: widget.meetupDate,
        respectfulnessRating: _respectfulnessRating,
        punctualityRating: _punctualityRating,
        conversationRating: _conversationRating,
        overallRating: _overallRating,
        showedUp: _showedUp,
        comment: _commentController.text.trim().isEmpty
            ? null
            : _commentController.text.trim(),
      );

      Navigator.of(context).pop(true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you for your feedback!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting rating: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rate Your Date',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'with ${widget.ratedUserName}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Did they show up?
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _showedUp
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _showedUp ? Colors.green : Colors.red,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _showedUp ? Icons.check_circle : Icons.cancel,
                      color: _showedUp ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Did they show up?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Switch(
                      value: _showedUp,
                      onChanged: (value) {
                        setState(() {
                          _showedUp = value;
                        });
                      },
                      activeColor: Colors.green,
                    ),
                  ],
                ),
              ),

              if (_showedUp) ...[
                const SizedBox(height: 24),

                // Rating categories
                _buildRatingCategory(
                  'Respectfulness',
                  Icons.favorite,
                  _respectfulnessRating,
                  (rating) => setState(() => _respectfulnessRating = rating),
                ),

                const SizedBox(height: 16),

                _buildRatingCategory(
                  'Punctuality',
                  Icons.schedule,
                  _punctualityRating,
                  (rating) => setState(() => _punctualityRating = rating),
                ),

                const SizedBox(height: 16),

                _buildRatingCategory(
                  'Conversation',
                  Icons.chat_bubble,
                  _conversationRating,
                  (rating) => setState(() => _conversationRating = rating),
                ),

                const SizedBox(height: 16),

                _buildRatingCategory(
                  'Overall Experience',
                  Icons.star_rate,
                  _overallRating,
                  (rating) => setState(() => _overallRating = rating),
                ),

                const SizedBox(height: 24),

                // Comment
                TextField(
                  controller: _commentController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Add a comment (optional)',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitRating,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.grey[700],
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Submit Rating',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                '💡 Your feedback helps maintain quality in our community',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingCategory(
    String title,
    IconData icon,
    int rating,
    Function(int) onRatingChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () => onRatingChanged(index + 1),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  index < rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 36,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
