class Employee {
  final int id;
  final String? name, email, password, address;

  Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.address,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'], 
      name: json['name'], 
      email: json['email'], 
      password: json['password'], 
      address: json['address'],
    );
  }

  @override
  String toString() {
    return 'id : $id, name : $name, email : $email, address : $address';
  }
}
