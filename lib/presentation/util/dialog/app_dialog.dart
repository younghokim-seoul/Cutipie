import 'package:cutipie/presentation/theme/app_color.dart';
import 'package:cutipie/presentation/theme/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';


class AppDialog extends Dialog {
  const AppDialog({
    Key? key,
    this.isDividedBtnFormat = false,
    this.showContentImg = true,
    this.description,
    this.subTitle,
    this.onLeftBtnClicked,
    this.leftBtnText,
    required this.btnText,
    required this.onBtnClicked,
    required this.title,
  }) : super(key: key);

  factory AppDialog.singleBtn({
    required String title,
    required VoidCallback onBtnClicked,
    String? subTitle,
    String? description,
    String? btnContent,
    bool? showContentImg,
  }) =>
      AppDialog(
        title: title,
        subTitle: subTitle,
        onBtnClicked: onBtnClicked,
        description: description,
        btnText: btnContent,
        showContentImg: showContentImg,
      );

  factory AppDialog.dividedBtn({
    required String title,
    String? description,
    String? subTitle,
    bool? showContentImg,
    required String leftBtnContent,
    required String rightBtnContent,
    required VoidCallback onRightBtnClicked,
    required VoidCallback onLeftBtnClicked,
  }) =>
      AppDialog(
        isDividedBtnFormat: true,
        title: title,
        subTitle: subTitle,
        onBtnClicked: onRightBtnClicked,
        onLeftBtnClicked: onLeftBtnClicked,
        description: description,
        leftBtnText: leftBtnContent,
        btnText: rightBtnContent,
        showContentImg: showContentImg,
      );

  final bool isDividedBtnFormat;
  final String title;
  final String? description;
  final VoidCallback onBtnClicked;
  final VoidCallback? onLeftBtnClicked;
  final String? btnText;
  final String? leftBtnText;
  final String? subTitle;
  final bool? showContentImg;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(minHeight: 120),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: AppColor.of.white,
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(163, 163, 179, 0.07),
              blurRadius: 65,
              offset: Offset(0, 5),
            ),
            BoxShadow(
              color: Color.fromRGBO(163, 163, 179, 0.07),
              blurRadius: 20,
              offset: Offset(0, 5.86471),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            /// Title
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyle.headline2,
              ),
            ),

            /// Sub Title
            if (subTitle != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  subTitle!,
                  style: AppTextStyle.body1.copyWith(
                    color: AppColor.of.gray5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            /// Description
            if (description != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8) +
                    const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  description!,
                  style: AppTextStyle.body3.copyWith(
                    color: AppColor.of.gray3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            // DividedButton

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8) +
                  const EdgeInsets.only(top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (isDividedBtnFormat)
                    Expanded(
                      flex: 1,
                      child: Row(
                        children: [
                          Expanded(
                            child: FilledButton(
                              onPressed: onLeftBtnClicked,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColor.of.gray1,
                                foregroundColor: AppColor.of.gray3,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 13,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                textStyle: AppTextStyle.title1,
                              ),
                              child: Text(
                                leftBtnText!,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (isDividedBtnFormat) const Gap(8),
                  Expanded(
                    flex: isDividedBtnFormat ? 1 : 0,
                    child: FilledButton(
                      onPressed: onBtnClicked,
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDividedBtnFormat ? 16 : 32,
                          vertical: 13,
                        ),
                      ),
                      child: Text(
                        btnText!,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}