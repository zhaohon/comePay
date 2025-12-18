import 'package:flutter/material.dart';
import 'package:comecomepay/core/base_viewmodel.dart';
import 'package:comecomepay/models/kyc_model.dart';
import 'package:comecomepay/services/kyc_service.dart';
import 'package:comecomepay/services/hive_storage_service.dart';

class KycViewModel extends BaseViewModel {
  final KycService _kycService = KycService();

  List<KycModel> _kycData = [];
  int _total = 0;
  String? _errorMessage;

  List<KycModel> get kycData => _kycData;
  int get total => _total;
  String? get errorMessage => _errorMessage;

  Future<void> fetchKycData() async {
    final email = HiveStorageService.getUser()?.email;
    if (email == null) {
      _errorMessage = 'User email not found';
      notifyListeners();
      return;
    }
    await fetchKycDataWithEmail(email);
  }

  Future<void> fetchKycDataWithEmail(String email) async {
    setBusy(true);
    _errorMessage = null;
    try {
      final result = await _kycService.getUserKyc(email);
      _total = result['total'];
      _kycData = result['list'];
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      setBusy(false);
    }
  }

  Future<void> refreshKycData() async {
    await fetchKycData();
  }
}
