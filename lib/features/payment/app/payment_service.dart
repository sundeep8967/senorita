import 'package:cloud_firestore/cloud_firestore.dart';
import '../../meetup/domain/models/meetup_model.dart';
import '../../meetup/domain/repositories/meetup_repository.dart';
import '../domain/models/payment_model.dart';
import '../domain/repositories/payment_repository.dart';

class PaymentService {
  final PaymentRepository _paymentRepository;
  final MeetupRepository _meetupRepository;

  PaymentService({
    required PaymentRepository paymentRepository,
    required MeetupRepository meetupRepository,
  })  : _paymentRepository = paymentRepository,
        _meetupRepository = meetupRepository;

  /// Initiates a paid meetup request.
  /// This function orchestrates the entire flow from payment to meetup creation.
  Future<bool> initiatePaidMeetup({
    required String requestingUserId,
    required String invitedUserId,
    required String hotelId,
    required String packageType,
    required double packageCost,
    required PaymentRequest paymentRequest,
  }) async {
    // Step 1: Process the payment
    final paymentResult = await _paymentRepository.processPayment(paymentRequest);

    if (paymentResult.status != PaymentResultStatus.success || paymentResult.transactionId == null) {
      print('Payment failed. Aborting meetup creation.');
      // Optionally, log the failed payment attempt
      return false;
    }

    print('Payment successful. Proceeding to create meetup and log payment.');

    // Step 2: Create the Meetup object
    final newMeetup = Meetup(
      id: '', // Firestore will generate the ID
      requestingUserId: requestingUserId,
      invitedUserId: invitedUserId,
      hotelId: hotelId,
      packageType: packageType,
      packageCost: packageCost,
      status: MeetupStatus.pending,
      createdAt: Timestamp.now(),
      paymentId: '', // We'll fill this in after logging the payment
    );

    // Step 3: Save the meetup to the database
    final meetupId = await _meetupRepository.createMeetup(newMeetup);

    // Step 4: Create the Payment log object
    final paymentLog = Payment(
      id: paymentResult.transactionId!, // Use the gateway's transaction ID
      userId: requestingUserId,
      meetupId: meetupId,
      amount: packageCost,
      currency: paymentRequest.currency,
      status: PaymentStatus.success,
      gateway: 'Razorpay', // Or get from a config
      gatewayTransactionId: paymentResult.transactionId,
      createdAt: Timestamp.now(),
    );

    // Step 5: Log the payment details
    await _paymentRepository.logPayment(paymentLog);

    // Step 6: Update the meetup with the final payment ID
    // This is important for data integrity, linking the two records.
    await _meetupRepository.updateMeetupStatus(meetupId, MeetupStatus.pending); // No status change, but can update fields
    // A better approach would be a transaction or a batch write to ensure atomicity.
    // For now, a simple update is fine.
    await _firestore.collection('meetups').doc(meetupId).update({'paymentId': paymentLog.id});


    print('Successfully created meetup $meetupId and logged payment ${paymentLog.id}.');
    return true;
  }

  // Helper to get firestore instance, in a real app this would be injected
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
}
