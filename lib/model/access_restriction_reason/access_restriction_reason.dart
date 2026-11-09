/// Values the backend sends in `errors.reason` when an action is blocked
/// for licensing/subscription reasons. [ApiService] fires its
/// access-restricted callback only for reasons listed in [all].
class AccessRestrictionReasons {
  static const String subscriptionRequired = 'SUBSCRIPTION_REQUIRED';

  static const Set<String> all = {subscriptionRequired};
}
