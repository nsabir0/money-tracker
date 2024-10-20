import 'package:flutter/material.dart';
import '../classes/app_bar.dart';
import '../classes/constants.dart';
import '../classes/input_model.dart';
import '../localization/methods.dart';
import 'input.dart';

class Edit extends StatelessWidget {
  static final _formKey3 = GlobalKey<FormState>(debugLabel: '_formKey3');
  final InputModel? inputModel;
  final IconData categoryIcon;
  const Edit({
    super.key,
    this.inputModel,
    required this.categoryIcon,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blue1,
      appBar: BasicAppBar(getTranslated(context, 'Edit')!),
      body: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: PanelForKeyboard(
            AddEditInput(
              formKey: _formKey3,
              inputModel: inputModel,
              categoryIcon: categoryIcon,
            ),
          )),
    );
  }
}
