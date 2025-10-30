class ApiService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // simula retraso
    return {
      'id': '1',
      'name': 'John Doe',
      'email': email,
    };
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // simula retraso
    return {
      'id': '2',
      'name': name,
      'email': email,
    };
  }
}
