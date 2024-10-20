import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../classes/app_bar.dart';
import '../classes/constants.dart';
import '../localization/methods.dart';
import '../provider.dart';
import 'add_category.dart';
import 'expense_category.dart';

class EditExpenseCategory extends StatefulWidget {
  final BuildContext buildContext;
  const EditExpenseCategory(this.buildContext, {super.key});
  @override
  EditExpenseCategoryState createState() => EditExpenseCategoryState();
}

class EditExpenseCategoryState extends State<EditExpenseCategory> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChangeExpenseItemEdit>(
        create: (context) => ChangeExpenseItemEdit(),
        child: Builder(
            builder: (contextEdit) => Scaffold(
                backgroundColor: blue1,
                appBar: EditCategoryAppBar(
                  AddCategory(
                      contextEx: widget.buildContext,
                      contextExEdit: contextEdit,
                      type: 'Expense',
                      appBarTitle:
                          getTranslated(context, 'Add Expense Category')!,
                      description: ''),
                ),
                body: ExpenseCategoryBody(
                  contextExEdit: contextEdit,
                  contextEx: widget.buildContext,
                ))));
  }
}
