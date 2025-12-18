// Model untuk request get profile
// Since it's a GET request with no body, this can be empty or used for consistency
class GetProfileRequestModel {
  // No fields needed for GET request
  GetProfileRequestModel();

  Map<String, dynamic> toJson() {
    return {};
  }
}
