import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NameInputStep extends StatefulWidget {
  final ValueChanged<String> onNameSubmitted;
  final String initialName;

  const NameInputStep({
    super.key,
    required this.onNameSubmitted,
    this.initialName = '',
  });

  @override
  State<NameInputStep> createState() => _NameInputStepState();
}

class _NameInputStepState extends State<NameInputStep> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    print('NameInputStep: Initializing with name: ${widget.initialName}');
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    if (_controller.text.trim().isNotEmpty) {
      print('NameInputStep: Submitting name - ${_controller.text.trim()}');
      widget.onNameSubmitted(_controller.text.trim());
    } else {
      print('NameInputStep: Empty name, not submitting');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top spacing - pushes content to bottom half
            const Spacer(flex: 5),
            
            // Title
            Text(
              "Let's begin",
              style: GoogleFonts.playfairDisplay(
                fontSize: 40,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 12),
            
            // Subtitle
            Text(
              "What's your name?",
              style: GoogleFonts.urbanist(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 32),
            
            // Input field with send button
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      autofocus: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        hintText: 'Your name',
                        hintStyle: GoogleFonts.urbanist(
                          color: Colors.black26,
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 18,
                        ),
                      ),
                      style: GoogleFonts.urbanist(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  // Send button
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: _submit,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8E0DC),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.send_rounded,
                          color: Color(0xFFFCB29C),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
