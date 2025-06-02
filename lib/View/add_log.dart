import 'package:flutter/material.dart';

class AddLogScreen extends StatefulWidget {
  const AddLogScreen({super.key});

  @override
  AddLogScreenState createState() => AddLogScreenState();
}

class AddLogScreenState extends State<AddLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _detailController = TextEditingController();
  final _purposeController = TextEditingController();
  final _nameController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeFromController = TextEditingController();
  final _timeToController = TextEditingController();
  final _initialMeterReadingController = TextEditingController();
  final _finalMeterReadingController = TextEditingController();
  final _remarksController = TextEditingController();
  final _kilometersCoveredController = TextEditingController();
  bool _isCalculatingKilometers = false;

  @override
  void initState() {
    super.initState();
    // Add listeners to the initial and final meter reading controllers
    _initialMeterReadingController.addListener(_calculateKilometersCovered);
    _finalMeterReadingController.addListener(_calculateKilometersCovered);
  }

  void _calculateKilometersCovered() {
    // If the kilometers covered field is currently being manually edited,
    // or if we are already in the process of calculating, avoid recursion.
    // This check is more relevant if _kilometersCoveredController also has a listener
    // that might trigger this function, or if user can edit the km field.
    // For now, simple check for _isCalculatingKilometers is enough.
    if (_isCalculatingKilometers) return;
    setState(() {
      _isCalculatingKilometers = true; // Mark that calculation is in progress

      final String initialText = _initialMeterReadingController.text;
      final String finalText = _finalMeterReadingController.text;

      final double? initialReading = double.tryParse(initialText);
      final double? finalReading = double.tryParse(finalText);

      if (initialReading != null && finalReading != null) {
        if (finalReading >= initialReading) {
          final double difference = finalReading - initialReading;
          // Format to a reasonable number of decimal places, e.g., 2
          _kilometersCoveredController.text = difference.toStringAsFixed(2);
        } else {
          // Handle invalid input, e.g., final reading is less than initial
          // You could clear the field or show an error specific to this logic
          _kilometersCoveredController.text = ""; // Or some error indicator like "Error"
        }
      } else {
        // If one or both fields are not valid numbers, clear the kilometers field
        _kilometersCoveredController.text = "";
      }
      _isCalculatingKilometers = false; // Calculation finished
    });
  }


  @override
  void dispose() {
    _nameController.dispose();
    _purposeController.dispose();
    _detailController.dispose();
    _dateController.dispose();
    _timeFromController.dispose();
    _timeToController.dispose();
    _initialMeterReadingController.dispose();
    _finalMeterReadingController.dispose();
    _remarksController.dispose();
    _kilometersCoveredController.dispose();
    super.dispose();
  }

  Future<void> _validateLog() async {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.green.shade300,
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Log saved successfully!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Log'), centerTitle: true),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: 'Name of Official',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the name of official';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _detailController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: 'Detail of Journey',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the detail of journey';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _purposeController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: 'Purpose of Journey',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the purpose of journey';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Date of Journey',
                  prefixIcon: Icon(Icons.date_range),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    _dateController.text =
                        "${pickedDate.toLocal()}".split(' ')[0];
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the date of journey';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _timeFromController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Time from Journey',
                  prefixIcon: Icon(Icons.access_time_filled_sharp),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                ),
                onTap: () async {
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                    initialEntryMode: TimePickerEntryMode.input,
                  );
                  if (pickedTime != null) {
                    _timeFromController.text = pickedTime.format(context);
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the time of journey';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _timeToController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Time to Journey',
                  prefixIcon: Icon(Icons.access_time_filled_sharp),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                ),
                onTap: () async {
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                    initialEntryMode: TimePickerEntryMode.input,
                  );
                  if (pickedTime != null) {
                    _timeToController.text = pickedTime.format(context);
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the time to journey';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _initialMeterReadingController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Initial Meter Reading',
                  prefixIcon: Icon(Icons.directions_car),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the initial meter reading';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _finalMeterReadingController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Final Meter Reading',
                  prefixIcon: Icon(Icons.directions_car),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the final meter reading';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _kilometersCoveredController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Kilometers Covered',
                  prefixIcon: Icon(Icons.directions_car),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    if (_initialMeterReadingController.text.isNotEmpty &&
                    _finalMeterReadingController.text.isNotEmpty){
                      return "Invalid Meter reading";
                    }
                    return null;
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _remarksController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: 'Remarks',
                  prefixIcon: Icon(Icons.comment),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the Remarks';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),

              ElevatedButton(
                onPressed: _validateLog,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text('Save', style: TextStyle(fontSize: 18.0)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
