import 'package:flutter/material.dart';

class AddFutsalPage extends StatefulWidget {
  const AddFutsalPage({super.key});

  @override
  _AddFutsalPageState createState() => _AddFutsalPageState();
}

class _AddFutsalPageState extends State<AddFutsalPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController scheduleController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  void addFutsal() async {
    if (_formKey.currentState!.validate()) {
      // Perform API call to add futsal
      print('Futsal added successfully');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Futsal')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Futsal Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Name cannot be empty' : null,
              ),
              TextFormField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (value) =>
                    value!.isEmpty ? 'Location cannot be empty' : null,
              ),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) =>
                    value!.isEmpty ? 'Description cannot be empty' : null,
              ),
              TextFormField(
                controller: scheduleController,
                decoration: const InputDecoration(labelText: 'Schedule'),
                validator: (value) =>
                    value!.isEmpty ? 'Schedule cannot be empty' : null,
              ),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Price cannot be empty' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: addFutsal,
                child: const Text('Add Futsal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
