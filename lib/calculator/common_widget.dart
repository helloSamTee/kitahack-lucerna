import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dropdown_search/dropdown_search.dart';

Widget buildTextField(
    BuildContext context, TextEditingController controller, String label,
    {bool isNumeric = false}) {
  return TextFormField(
      controller: controller,
      keyboardType: isNumeric
          ? TextInputType.number
          : TextInputType.text, // Allow only numbers if needed
      inputFormatters: isNumeric
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))]
          : [],
      decoration: InputDecoration(
        labelText: label,
        labelStyle: Theme.of(context).textTheme.labelSmall,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Color.fromRGBO(0, 0, 0, 0.5))),
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      // Validator to check for empty fields
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label cannot be empty. Please enter a valid value.';
        }
        if (isNumeric) {
          // Check if the input is numeric
          final num? numericValue = num.tryParse(value);
          if (numericValue != null) {
            if (numericValue <= 0) {
              return '$label must be a positive value. Please enter either a text description or a valid numerical value.';
            }
          }
        }
        return null;
      });
}

// Widget _buildDropdown(List<String> all_items) {
//     return DropdownSearch<String>(
//       items: all_items,
//       dropdownDecoratorProps: DropDownDecoratorProps(
//         dropdownSearchDecoration: InputDecoration(
//           labelText: "Country",
//           labelStyle: Theme.of(context).textTheme.labelSmall,
//           filled: true,
//           fillColor: Colors.white,
//           border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//               borderSide: BorderSide(color: Color.fromRGBO(0, 0, 0, 0.5))),
//         ),
//       ),
//       validator: (value) {
//         if (value == null) {
//           return 'Please select a country';
//         }
//         return null;
//       },
//       onChanged: (value) {
//         setState(() {
//           selectedCountry = value!;
//         });
//       },
//       selectedItem: selectedCountry,
//       filterFn: (item, filter) =>
//           item.toLowerCase().contains(filter.toLowerCase()),
//       popupProps: PopupProps.menu(
//         showSearchBox: true,
//         searchFieldProps: TextFieldProps(
//           decoration: InputDecoration(
//             labelText: "Type to search",
//             border: OutlineInputBorder(),
//           ),
//         ),
//       ),
//     );
//   }

class buildDropdown extends StatefulWidget {
  final List<String> items;
  final String label;
  final String defaultValue;
  final Function(String) onChanged;

  const buildDropdown({
    super.key,
    required this.items,
    required this.label,
    required this.defaultValue,
    required this.onChanged,
  });

  @override
  _buildDropdownState createState() => _buildDropdownState();
}

class _buildDropdownState extends State<buildDropdown> {
  late String selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.defaultValue; // Initialize selected value
  }

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<String>(
      items: widget.items,
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: widget.label,
          labelStyle: Theme.of(context).textTheme.labelSmall,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color.fromRGBO(0, 0, 0, 0.5)),
          ),
        ),
      ),
      validator: (value) {
        if (value == null) {
          return 'Please select an option';
        }
        return null;
      },
      onChanged: (value) {
        if (value != null) {
          setState(() {
            selectedValue = value;
          });
          widget.onChanged(value); // Pass new value back to parent widget
        }
      },
      selectedItem: selectedValue,
      filterFn: (item, filter) =>
          item.toLowerCase().contains(filter.toLowerCase()),
      popupProps: PopupProps.menu(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          decoration: const InputDecoration(
            labelText: "Type to search",
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}

class buildCheckbox extends StatefulWidget {
  final Function(String) onChanged; // Callback function to pass value to parent
  final String label;

  const buildCheckbox(
      {super.key, required this.onChanged, required this.label});

  @override
  _buildCheckboxState createState() => _buildCheckboxState();
}

class _buildCheckboxState extends State<buildCheckbox> {
  bool isChecked = true; // ✅ Default to "Y"

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(widget.label),
      value: isChecked,
      onChanged: (bool? value) {
        setState(() {
          isChecked = value ?? false;
        });

        // ✅ Pass "Y" or "N" back to the parent widget
        widget.onChanged(isChecked ? "Y" : "N");
      },
      controlAffinity: ListTileControlAffinity.leading, // Checkbox on left side
    );
  }
}
