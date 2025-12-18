class CreateWalletRequestModel {
  final String tenantName;
  final String tenantExternalId;
  final String chain;
  final String label;
  final String custody;

  CreateWalletRequestModel({
    required this.tenantName,
    required this.tenantExternalId,
    required this.chain,
    required this.label,
    required this.custody,
  });

  Map<String, dynamic> toJson() {
    return {
      'tenant_name': tenantName,
      'tenant_external_id': tenantExternalId,
      'chain': chain,
      'label': label,
      'custody': custody,
    };
  }

  factory CreateWalletRequestModel.fromJson(Map<String, dynamic> json) {
    return CreateWalletRequestModel(
      tenantName: json['tenant_name'],
      tenantExternalId: json['tenant_external_id'],
      chain: json['chain'],
      label: json['label'],
      custody: json['custody'],
    );
  }
}
