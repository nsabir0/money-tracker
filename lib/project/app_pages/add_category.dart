import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../classes/app_bar.dart';
import '../classes/category_item.dart';
import '../classes/constants.dart';
import '../classes/save_or_save_and_delete_buttons.dart';
import '../database_management/shared_preferences_services.dart';
import '../localization/methods.dart';
import '../provider.dart';
import 'parent_category.dart';
import 'select_icon.dart';

class AddCategory extends StatelessWidget {
  final BuildContext? contextEx, contextExEdit, contextInEdit, contextIn;
  final String type, appBarTitle;
  final String? categoryName, description;
  final IconData? categoryIcon;
  final CategoryItem? parentItem;
  static final _formKey4 = GlobalKey<FormState>(debugLabel: '_formKey4'),
      _formKey5 = GlobalKey<FormState>(debugLabel: '_formKey5');
  const AddCategory(
      {super.key,
      this.contextExEdit,
      this.contextEx,
      this.contextInEdit,
      this.contextIn,
      required this.type,
      required this.appBarTitle,
      this.categoryName,
      this.categoryIcon,
      this.parentItem,
      this.description});

  void unFocusNode(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          unFocusNode(context);
        },
        child: Scaffold(
          backgroundColor: blue1,
          appBar: BasicAppBar(appBarTitle),
          body: Form(
            key: type == 'Income' ? _formKey4 : _formKey5,
            child: ChangeNotifierProvider<ChangeCategory>(
              create: (context) => ChangeCategory(),
              child: ListView(
                children: [
                  CategoryName(
                      type,
                      categoryName == null
                          ? null
                          : getTranslated(context, categoryName!) ??
                              categoryName,
                      categoryIcon),
                  // Hide ParentCategoryCard when either type is Income or users press on parent category
                  // Fix this? why not (this.categoryName == null && this.parentCategory != null)
                  type == 'Income' ||
                          (categoryName != null && parentItem == null)
                      ? const SizedBox()
                      : ParentCategoryCard(parentItem),
                  SizedBox(
                    height: 20.h,
                  ),
                  Description(description),
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 90.h),
                      child: Save(
                          formKey: type == 'Income' ? _formKey4 : _formKey5,
                          contextEx: contextEx,
                          contextExEdit: contextExEdit,
                          contextIn: contextIn,
                          contextInEdit: contextInEdit,
                          categoryName: categoryName,
                          categoryIcon: categoryIcon,
                          parentItem: parentItem,
                          description: description))
                ],
              ),
            ),
          ),
        ));
  }
}

class CategoryName extends StatefulWidget {
  final String type;
  final String? categoryName;
  final IconData? categoryIcon;
  const CategoryName(this.type, this.categoryName, this.categoryIcon,
      {super.key});
  @override
  CategoryNameState createState() => CategoryNameState();
}

class CategoryNameState extends State<CategoryName> {
  // late final FocusNode categoryNameFocusNode;
  static late TextEditingController categoryNameController;
  final FocusNode categoryNameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // categoryNameFocusNode = FocusNode();
    categoryNameController =
        TextEditingController(text: widget.categoryName ?? '');
  }

  // @override
  // void dispose() {
  //   categoryNameFocusNode.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 7,
      child: Padding(
        padding: EdgeInsets.only(left: 10.w, top: 8.h, bottom: 8.h),
        child: TextFormField(
          controller: categoryNameController,
          focusNode: categoryNameFocusNode,
          onChanged: (value) => {},
          maxLines: null,
          cursorColor: blue1,
          textCapitalization: TextCapitalization.sentences,
          style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
          validator: (categoryNameInput) {
            categoryNameInput = categoryNameInput!.trim();
            if (categoryNameInput.isEmpty) {
              return getTranslated(context, 'Please fill a category name');
            } else {
              bool isIdenticalCategory() {
                if (widget.type == 'Income') {
                  for (CategoryItem incomeItem in incomeItems) {
                    if (categoryNameInput == incomeItem.text) {
                      return true;
                    }
                  }
                } else {
                  List<CategoryItem> expenseItems = [];

                  // sharedPrefs.getAllExpenseItemsLists().forEach(
                  //     (parentExpenseItem) => parentExpenseItem.forEach(
                  //         (expenseItem) => expenseItems.add(expenseItem)));
                  for (var parentExpenseItem
                      in sharedPrefs.getAllExpenseItemsLists()) {
                    for (var expenseItem in parentExpenseItem) {
                      expenseItems.add(expenseItem);
                    }
                  }

                  for (CategoryItem expenseItem in expenseItems) {
                    if (categoryNameInput == expenseItem.text) {
                      return true;
                    }
                  }
                }
                return false;
              }

              // Show an error if users want to edit to or add an existing category
              if ((categoryNameInput != widget.categoryName) &&
                  (isIdenticalCategory())) {
                return getTranslated(context, 'Category already exists');
              }
            }
            return null;
          },
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: getTranslated(context, 'Category name'),
              hintStyle: TextStyle(
                  fontSize: 22.sp,
                  color: grey,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.normal),
              suffixIcon: categoryNameController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        categoryNameController.clear();
                      })
                  : const SizedBox(),
              icon: Selector<ChangeCategory, IconData?>(
                  selector: (_, provider) => provider.selectedCategoryIcon,
                  builder: (context, selectedCategoryIcon, child) {
                    return GestureDetector(
                      onTap: () async {
                        IconData? selectedIcon = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        SelectIcon(widget.type))) ??
                            selectedCategoryIcon;

                        context
                            .read<ChangeCategory>()
                            .changeCategoryIcon(selectedIcon);
                      },
                      child: Column(
                        children: [
                          CircleAvatar(
                              radius: 20.r,
                              backgroundColor:
                                  const Color.fromRGBO(215, 223, 231, 1),
                              child: Icon(
                                selectedCategoryIcon ??
                                    widget.categoryIcon ??
                                    Icons.category_outlined,
                                size: 25.sp,
                                color: widget.type == 'Income' ? green : red,
                              )),
                          const SizedBox(
                            height: 2,
                          ),
                          const Text(
                            'select icon',
                            style:
                                TextStyle(fontSize: 11, color: Colors.blueGrey),
                          )
                        ],
                      ),
                    );
                  })),
        ),
      ),
    );
  }
}

class ParentCategoryCard extends StatefulWidget {
  final CategoryItem? parentItem;
  const ParentCategoryCard(this.parentItem, {super.key});
  @override
  ParentCategoryCardState createState() => ParentCategoryCardState();
}

class ParentCategoryCardState extends State<ParentCategoryCard> {
  @override
  Widget build(BuildContext context) {
    return Selector<ChangeCategory, CategoryItem?>(
        selector: (_, provider) => provider.parentItem,
        builder: (context, selectedParentItem, child) {
          selectedParentItem ??= widget.parentItem ??
              categoryItem(Icons.category_outlined,
                  getTranslated(context, 'Parent category')!);
          context.read<ChangeCategory>().parentItem = selectedParentItem;
          return GestureDetector(
              onTap: () async {
                CategoryItem newParentItem = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ParentCategoryList()));
                context.read<ChangeCategory>().changeParentItem(newParentItem);
              },
              child: Card(
                elevation: 7,
                child: Padding(
                  padding: EdgeInsets.only(left: 18.w, top: 6.h, bottom: 6.h),
                  child: Row(
                    children: [
                      CircleAvatar(
                          radius: 20.r,
                          backgroundColor:
                              const Color.fromRGBO(215, 223, 231, 1),
                          child: Icon(
                            iconData(selectedParentItem),
                            size: 25.sp,
                            color: red,
                          )),
                      SizedBox(
                        width: 28.w,
                      ),
                      Text(
                        getTranslated(context, selectedParentItem.text) ??
                            selectedParentItem.text,
                        style: selectedParentItem.text ==
                                getTranslated(context, 'Parent category')!
                            ? TextStyle(
                                fontSize: 22.sp,
                                color: grey,
                                fontStyle: FontStyle.italic,
                              )
                            : TextStyle(
                                fontSize: 22.sp,
                                color: red,
                                fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 22.sp,
                      ),
                      SizedBox(
                        width: 10.h,
                      )
                    ],
                  ),
                ),
              ));
        });
  }
}

class Description extends StatefulWidget {
  final String? description;
  const Description(this.description, {super.key});
  @override
  DescriptionState createState() => DescriptionState();
}

class DescriptionState extends State<Description> {
  final FocusNode descriptionFocusNode = FocusNode();
  static late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    descriptionController =
        TextEditingController(text: widget.description ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 7,
      child: SizedBox(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 6.h),
          child: TextFormField(
              controller: descriptionController,
              focusNode: descriptionFocusNode,
              maxLines: null,
              minLines: 1,
              cursorColor: blue1,
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(fontSize: 22.sp),
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText:
                      getTranslated(context, 'Description') ?? 'Description',
                  hintStyle: GoogleFonts.cousine(
                    fontSize: 21.5.sp,
                    fontStyle: FontStyle.italic,
                  ),
                  suffixIcon: descriptionController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            descriptionController.clear();
                          })
                      : const SizedBox(),
                  icon: Padding(
                    padding: EdgeInsets.only(right: 10.w),
                    child: Icon(
                      Icons.description_outlined,
                      size: 35.sp,
                      color: Colors.blueGrey,
                    ),
                  ))),
        ),
      ),
    );
  }
}

class Save extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final BuildContext? contextEx, contextExEdit, contextIn, contextInEdit;
  final String? categoryName, description;
  final IconData? categoryIcon;
  final CategoryItem? parentItem;
  const Save(
      {super.key,
      required this.formKey,
      this.contextEx,
      this.contextExEdit,
      this.contextIn,
      this.contextInEdit,
      this.categoryName,
      this.categoryIcon,
      this.parentItem,
      this.description});

  @override
  SaveState createState() => SaveState();
}

class SaveState extends State<Save> {
  @override
  Widget build(BuildContext context) {
    void saveCategoryFunction() {
      if (widget.formKey.currentState!.validate()) {
        String? finalDescription = DescriptionState.descriptionController.text;
        String finalCategoryName =
            CategoryNameState.categoryNameController.text;
        IconData? finalCategoryIcon =
            Provider.of<ChangeCategory>(context, listen: false)
                .selectedCategoryIcon;
        // trim to get a real input
        finalCategoryName = finalCategoryName.trim();
        finalDescription = finalDescription.trim();

        CategoryItem categoryItem(IconData iconData) => CategoryItem(
            iconData.codePoint,
            iconData.fontPackage,
            iconData.fontFamily,
            finalCategoryName,
            finalDescription);

        void updateCategory() {
          Provider.of<ChangeExpenseItemEdit>(widget.contextExEdit!,
                  listen: false)
              .getAllExpenseItems();
          Provider.of<ChangeExpenseItem>(widget.contextEx!, listen: false)
              .getAllExpenseItems();
        }

        if (widget.contextInEdit != null) {
          log('income');
          if (widget.categoryName != null) {
            log('edit');
            if (finalCategoryName != widget.categoryName ||
                widget.categoryIcon != finalCategoryIcon ||
                widget.description != finalDescription) {
              log('something changed');
              incomeItems
                  .removeWhere((item) => item.text == widget.categoryName);
            }
          }
          incomeItems.add(categoryItem(finalCategoryIcon ??
              widget.categoryIcon ??
              Icons.category_outlined));
          sharedPrefs.saveItems('income items', incomeItems);
          Provider.of<ChangeIncomeItemEdit>(widget.contextInEdit!,
                  listen: false)
              .getIncomeItems();
          if (widget.contextIn != null) {
            Provider.of<ChangeIncomeItem>(widget.contextIn!, listen: false)
                .getIncomeItems();
          }
        } else {
          log('expense');
          CategoryItem? finalParent = context.read<ChangeCategory>().parentItem;

          if ((widget.categoryName == null) && (widget.parentItem == null)) {
            CategoryItem item =
                categoryItem(finalCategoryIcon ?? Icons.category_outlined);
            log('add expense');
            if (finalParent!.text ==
                getTranslated(context, 'Parent category')!) {
              log('add parent');
              sharedPrefs.saveItems(finalCategoryName, [item]);

              var parentExpenseItemNames = sharedPrefs.parentExpenseItemNames;
              parentExpenseItemNames.add(finalCategoryName);
              sharedPrefs.parentExpenseItemNames = parentExpenseItemNames;
            } else {
              log('add new expense category to an existing parent');
              List<CategoryItem> items = sharedPrefs.getItems(finalParent.text);
              items.add(item);
              sharedPrefs.saveItems(finalParent.text, items);
            }
            updateCategory();
          } else {
            log('edit');
            if (widget.parentItem == null) {
              log('edit parent only');
              if (finalCategoryName != widget.categoryName ||
                  widget.categoryIcon != finalCategoryIcon ||
                  widget.description != finalDescription) {
                log('something changed');
                List<CategoryItem> items =
                    sharedPrefs.getItems(widget.categoryName!);
                items.removeAt(0);
                items.insert(
                    0, categoryItem(finalCategoryIcon ?? widget.categoryIcon!));

                sharedPrefs.saveItems(finalCategoryName, items);
                if (finalCategoryName != widget.categoryName) {
                  log('parent name changed');
                  var parentExpenseItemNames =
                      sharedPrefs.parentExpenseItemNames;

                  parentExpenseItemNames.removeWhere((parentExpenseItemName) =>
                      widget.categoryName == parentExpenseItemName);
                  parentExpenseItemNames.insert(0, finalCategoryName);
                  sharedPrefs.parentExpenseItemNames = parentExpenseItemNames;
                }
                updateCategory();
              }
            } else {
              log('edit category');
              if (finalParent!.text != widget.parentItem!.text ||
                  widget.categoryIcon != finalCategoryIcon ||
                  finalCategoryName != widget.categoryName ||
                  widget.description != finalDescription) {
                log('something changed');
                void itemsAdd(List<CategoryItem> items) {
                  items.add(
                      categoryItem(finalCategoryIcon ?? widget.categoryIcon!));
                }

                List<CategoryItem> items =
                    sharedPrefs.getItems(widget.parentItem!.text);
                items.removeWhere((item) => item.text == widget.categoryName);

                if (finalParent.text != widget.parentItem!.text) {
                  log('edit parent of expense category');
                  List<CategoryItem> itemsMovedTo =
                      sharedPrefs.getItems(finalParent.text);
                  itemsAdd(itemsMovedTo);
                  sharedPrefs.saveItems(finalParent.text, itemsMovedTo);
                } else {
                  log('edit other things');
                  itemsAdd(items);
                }
                sharedPrefs.saveItems(widget.parentItem!.text, items);
                updateCategory();
              }
            }
          }
        }
        Navigator.pop(context);
      }
    }

    if (widget.categoryName == null && widget.parentItem == null) {
      return SaveButton(false, saveCategoryFunction, null);
    } else {
      return SaveAndDeleteButton(
          saveAndDeleteInput: false,
          saveCategory: saveCategoryFunction,
          categoryName: widget.categoryName,
          parentExpenseItem: widget.parentItem?.text,
          contextEx: widget.contextEx,
          contextExEdit: widget.contextExEdit,
          contextIn: widget.contextIn,
          contextInEdit: widget.contextInEdit);
    }
  }
}
