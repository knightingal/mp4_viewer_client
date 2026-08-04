import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:mp4_viewer_client/main.dart';

class SettingsPage extends StatelessWidget {
  @Preview(name: 'Settings Page')
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: SettingsWidget(),
    );
  }
}

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({super.key});

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  final TextEditingController controller = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? forceErrorText;
  bool isLoading = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  String? validator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    if (value.length != value.replaceAll(' ', '').length) {
      return 'Address must not contain any spaces';
    }
    if (value.length <= 2) {
      return 'Address should be at least 3 characters long';
    }
    return null;
  }

  void onChanged(String value) {
    // Nullify forceErrorText if the input changed.
    if (forceErrorText != null) {
      setState(() {
        forceErrorText = null;
      });
    }
  }

  Future<void> onSave() async {
    // Providing a default value in case this was called on the
    // first frame, the [fromKey.currentState] will be null.
    final bool isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    setState(() => isLoading = true);
    final String? errorText = await validateAddress(controller.text);

    if (context.mounted) {
      setState(() => isLoading = false);
      apiAddress = controller.text;

      if (errorText != null) {
        setState(() {
          forceErrorText = errorText;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: const .symmetric(horizontal: 24.0),
        child: Center(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: .center,
              children: <Widget>[
                TextFormField(
                  forceErrorText: forceErrorText,
                  controller: controller,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Server Address",
                    hintText: 'Please write a username',
                  ),
                  validator: validator,
                  onChanged: onChanged,
                ),
                const SizedBox(height: 40.0),
                if (isLoading)
                  const CircularProgressIndicator()
                else
                  TextButton(onPressed: onSave, child: const Text('Save')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const Duration kFakeHttpRequestDuration = Duration(milliseconds: 500);

Future<String?> validateAddress(String address) async {
  await Future<void>.delayed(kFakeHttpRequestDuration);

  return null;
}
