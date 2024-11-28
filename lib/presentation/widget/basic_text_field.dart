
import 'package:cutipie/presentation/theme/app_color.dart';
import 'package:cutipie/presentation/theme/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class IcoTextFormField extends StatelessWidget {
  IcoTextFormField({
    Key? key,
    required this.width,
    this.onChanged,
    this.myTextController,
    this.myValidator,
    this.textFieldLabel = '',
    this.hintText,
    this.obscureText = false,
    this.isJustLoaded = true,
    this.isErrorTextLabel = true,
    this.maxLength = 30,
    required this.keyboardType,
    this.showErrorText = true,
    this.textInputFormatter,
  }) : super(key: key);

  final Function(String)? onChanged;
  final String? myValidator;
  var myTextController;
  final String? hintText;
  final bool obscureText;
  String? textFieldLabel;
  bool isJustLoaded;
  double width;
  bool isErrorTextLabel;
  int maxLength;
  bool showErrorText;
  TextInputType keyboardType;
  List<TextInputFormatter>? textInputFormatter;

  @override
  Widget build(BuildContext context) {

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (textFieldLabel != '') Column(
            children: [
              Text(
                textFieldLabel!,
                style: AppTextStyle.title2,
              ),
              const SizedBox(
                height: 9,
              ),
            ],
          ) else SizedBox(),
          SizedBox(
            height: 50,
            width: width,
            child: TextFormField(
              inputFormatters: textInputFormatter,
              keyboardType: keyboardType,
              maxLength: maxLength,
              obscureText: obscureText,
              controller: myTextController,
              onChanged: onChanged,
              decoration: InputDecoration(
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                hintText: hintText,
                hintStyle: AppTextStyle.body2,
                errorStyle: const TextStyle(height: 0, color: Colors.transparent),
                focusedBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide(color: AppColor().brand2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide(color: AppColor().green1),
                ),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
              ),
            ),
          ),
        ],
      );
  }
}