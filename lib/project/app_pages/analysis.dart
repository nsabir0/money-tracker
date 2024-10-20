import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../classes/app_bar.dart';
import '../classes/category_item.dart';
import '../classes/chart_pie.dart';
import '../classes/constants.dart';
import '../classes/dropdown_box.dart';
import '../classes/input_model.dart';
import '../database_management/shared_preferences_services.dart';
import '../database_management/sqflite_services.dart';
import '../localization/methods.dart';
import '../provider.dart';
import 'report.dart';

final List<InputModel> chartDataNull = [
  InputModel(
      id: null,
      type: null,
      amount: 1,
      category: '',
      description: null,
      date: null,
      time: null,
      color: const Color.fromRGBO(0, 220, 252, 1))
];

class Analysis extends StatefulWidget {
  const Analysis({super.key});

  @override
  AnalysisState createState() => AnalysisState();
}

class AnalysisState extends State<Analysis> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChangeSelectedDate>(
      create: (context) => ChangeSelectedDate(),
      child: DefaultTabController(
        initialIndex: 0,
        length: 2,
        child: Scaffold(
            backgroundColor: blue1,
            appBar: const InExAppBar(false),
            body: Selector<ChangeSelectedDate, String?>(
                selector: (_, changeSelectedDate) =>
                    changeSelectedDate.selectedAnalysisDate,
                builder: (context, selectedAnalysisDate, child) {
                  selectedAnalysisDate ??= sharedPrefs.selectedDate;
                  ListView listViewChild(String type) => ListView(
                        children: [
                          ShowDate(true, selectedAnalysisDate!),
                          ShowDetails(type, selectedAnalysisDate),
                        ],
                      );
                  return TabBarView(
                    children: [
                      listViewChild('Expense'),
                      listViewChild('Income')
                    ],
                  );
                })),
      ),
    );
  }
}

class ShowDate extends StatelessWidget {
  final bool forAnalysis;
  final String selectedDate;
  const ShowDate(this.forAnalysis, this.selectedDate, {super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 10.w,
          vertical: 25.h,
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 27.sp,
              color: const Color.fromRGBO(82, 179, 252, 1),
            ),
            SizedBox(
              width: 10.w,
            ),
            DateDisplay(selectedDate),
            const Spacer(),
            DropDownBox(forAnalysis, selectedDate)
          ],
        ));
  }
}

class DateDisplay extends StatelessWidget {
  final String selectedDate;
  const DateDisplay(this.selectedDate, {super.key});

  @override
  Widget build(BuildContext context) {
    final String today = DateFormat(sharedPrefs.dateFormat).format(todayDT);
    String since = getTranslated(context, 'Since')!;
    TextStyle style =
        GoogleFonts.aBeeZee(fontSize: 20.sp, fontWeight: FontWeight.bold);

    Map<String, Widget> dateMap = {
      'Today': Text(today, style: style),
      'This week': Text(
        '$since ${DateFormat(sharedPrefs.dateFormat).format(startOfThisWeek)}',
        style: style,
      ),
      'This month': Text(
          '$since ${DateFormat(sharedPrefs.dateFormat).format(startOfThisMonth)}',
          style: style),
      'This quarter': Text(
        '$since ${DateFormat(sharedPrefs.dateFormat).format(startOfThisQuarter)}',
        style: style,
      ),
      'This year': Text(
        '$since ${DateFormat(sharedPrefs.dateFormat).format(startOfThisYear)}',
        style: style,
      ),
      'All': Text(getTranslated(context, 'All')!, style: style)
    };
    var dateListKey = dateMap.keys.toList();
    var dateListValue = dateMap.values.toList();

    for (int i = 0; i < dateListKey.length; i++) {
      if (selectedDate == dateListKey[i]) {
        return dateListValue[i];
      }
    }
    return Container();
  }
}

class ShowMoneyFrame extends StatelessWidget {
  final String type;
  final double typeValue, balance;
  const ShowMoneyFrame(this.type, this.typeValue, this.balance, {super.key});

  @override
  Widget build(BuildContext context) {
    Widget rowFrame(String typeName, double value) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            getTranslated(context, typeName)!,
            style: TextStyle(fontSize: 22.sp),
          ),
          Expanded(
            child: Text(
              '${format(value)} $currency',
              style: GoogleFonts.aBeeZee(
                  fontSize: format(value.toDouble()).length > 22
                      ? 16.5.sp
                      : format(value.toDouble()).length > 17
                          ? 19.5.sp
                          : 22.sp),
              // fix here: Overflow is a temporary parameter, fix whatever it is so that the money value will never overflow
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      );
    }

    return Container(
      decoration: BoxDecoration(
          color: const Color.fromRGBO(239, 247, 253, 1),
          borderRadius: BorderRadius.circular(40.r),
          border: Border.all(
            color: grey,
            width: 0.4.w,
          )),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.5.h),
        child: Column(
          children: [
            rowFrame(type, typeValue),
            SizedBox(
              height: 12.5.h,
            ),
            rowFrame('Balance', balance)
          ],
        ),
      ),
    );
  }
}

class ShowDetails extends StatefulWidget {
  final String type, selectedDate;
  const ShowDetails(this.type, this.selectedDate, {super.key});

  @override
  ShowDetailsState createState() => ShowDetailsState();
}

class ShowDetailsState extends State<ShowDetails> {
  Widget showInExDetails(
    BuildContext context,
    List<InputModel> transactionsSorted,
  ) {
    List<CategoryItem> itemList = widget.type == 'Income'
        ? createItemList(
            transactions: transactionsSorted,
            forAnalysisPage: true,
            isIncomeType: true,
            forSelectIconPage: false)
        : createItemList(
            transactions: transactionsSorted,
            forAnalysisPage: true,
            isIncomeType: false,
            forSelectIconPage: false);

    return Column(
        children: List.generate(itemList.length, (int count) {
      return
          // SwipeActionCell(
          // backgroundColor: Colors.transparent,
          //   key: ObjectKey(transactionsSorted[count]),
          //   performsFirstActionWithFullSwipe: true,
          //   trailingActions: <SwipeAction>[
          //     SwipeAction(
          //         title: "Delete",
          //         onTap: (CompletionHandler handler) async {
          //           Future<void> onDeletion() async {
          //             await handler(true);
          //             transactionsSorted.removeAt(count);
          //             customToast(context, 'Transactions has been deleted');
          //             setState(() {});
          //           }
          //
          //           Platform.isIOS
          //               ? await iosDialog(
          //                   context,
          //                   'Deleted data can not be recovered. Are you sure you want to Delete All Transactions In This Category?',
          //                   'Delete',
          //                   onDeletion)
          //               : await androidDialog(
          //                   context,
          //                   'Deleted data can not be recovered. Are you sure you want to Delete All Transactions In This Category?',
          //                   'Delete',
          //                   onDeletion);
          //         },
          //         color: red),
          //   ], child:
          GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Report(
                              type: widget.type,
                              category: itemList[count].text,
                              selectedDate: widget.selectedDate,
                              icon: iconData(itemList[count]),
                            ))).then((value) => setState(() {}));
              },
              child: CategoryDetails(
                  widget.type,
                  getTranslated(context, itemList[count].text) ??
                      itemList[count].text,
                  transactionsSorted[count].amount!,
                  transactionsSorted[count].color,
                  iconData(itemList[count]),
                  false));
    }));
  }

  @override
  Widget build(BuildContext context) {
    late Map<String, double> chartDataMap;
    return FutureBuilder<List<InputModel>>(
        initialData: const [],
        future: DB.inputModelList(),
        builder:
            (BuildContext context, AsyncSnapshot<List<InputModel>> snapshot) {
          connectionUI(snapshot);
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ShowNullDetail(0, null, widget.type, false);
          }
          if (snapshot.data == null) {
            return ShowNullDetail(0, chartDataNull, widget.type, true);
          } else {
            double income = 0, expense = 0, balance = 0;

            List<InputModel> allTransactions =
                filterData(context, snapshot.data!, widget.selectedDate);

            if (allTransactions.isNotEmpty) {
              //prepare for MoneyFrame

              List<double?> incomeList = [], expenseList = [];
              incomeList = allTransactions
                  .map((data) {
                    if (data.type == 'Income') {
                      return data.amount;
                    }
                  })
                  .where((element) => element != null)
                  .toList();

              expenseList = allTransactions
                  .map((data) {
                    if (data.type == 'Expense') {
                      return data.amount;
                    }
                  })
                  .where((element) => element != null)
                  .toList();

              if (incomeList.isNotEmpty) {
                for (int i = 0; i < incomeList.length; i++) {
                  income = income + incomeList[i]!;
                }
              }
              if (expenseList.isNotEmpty) {
                for (int i = 0; i < expenseList.length; i++) {
                  expense = expense + expenseList[i]!;
                }
              }
              balance = income - expense;

              // prepare for InExDetails
              if (widget.type == 'Income') {
                allTransactions = allTransactions
                    .map((data) {
                      if (data.type == 'Income') {
                        return inputModel(data);
                      }
                    })
                    .where((element) => element != null)
                    .cast<InputModel>()
                    .toList();
              } else {
                allTransactions = allTransactions
                    .map((data) {
                      if (data.type == 'Expense') {
                        return inputModel(data);
                      }
                    })
                    .where((element) => element != null)
                    .cast<InputModel>()
                    .toList();
              }
            }

            if (allTransactions.isEmpty) {
              return ShowNullDetail(balance, chartDataNull, widget.type, true);
            } else {
              List<InputModel> transactionsSorted = [
                InputModel(
                  type: widget.type,
                  amount: allTransactions[0].amount,
                  category: allTransactions[0].category,
                )
              ];

              int i = 1;
              //cmt: chartDataListDetailed.length must be greater than 2 to execute
              while (i < allTransactions.length) {
                allTransactions
                    .sort((a, b) => a.category!.compareTo(b.category!));

                if (i == 1) {
                  chartDataMap = {
                    allTransactions[0].category!: allTransactions[0].amount!
                  };
                }

                if (allTransactions[i].category ==
                    allTransactions[i - 1].category) {
                  chartDataMap.update(allTransactions[i].category!,
                      (value) => (value + allTransactions[i].amount!),
                      ifAbsent: () => (allTransactions[i - 1].amount! +
                          allTransactions[i].amount!));
                  i++;
                } else {
                  chartDataMap.addAll({
                    allTransactions[i].category!: allTransactions[i].amount!
                  });

                  i++;
                }
                transactionsSorted = chartDataMap.entries
                    .map((entry) => InputModel(
                          type: widget.type,
                          category: entry.key,
                          amount: entry.value,
                        ))
                    .toList();
              }

              void recurringFunc({required int i, n}) {
                if (n > i) {
                  for (int c = 1; c <= n - i; c++) {
                    transactionsSorted[i + c - 1].color = chartPieColors[c - 1];
                    recurringFunc(i: i, n: c);
                  }
                }
              }

              for (int n = 1; n <= transactionsSorted.length; n++) {
                transactionsSorted[n - 1].color = chartPieColors[n - 1];
                recurringFunc(i: chartPieColors.length, n: n);
              }
              return Column(
                children: [
                  ShowMoneyFrame(widget.type,
                      widget.type == 'Income' ? income : expense, balance),
                  SizedBox(height: 360.h, child: ChartPie(transactionsSorted)),
                  showInExDetails(
                    context,
                    // sum value of transactions having a same category to one
                    transactionsSorted,
                  )
                ],
              );
            }
          }
        });
  }
}

class ShowNullDetail extends StatelessWidget {
  final double balanceValue;
  final List<InputModel>? chartData;
  final String type;
  final bool connection;
  const ShowNullDetail(
      this.balanceValue, this.chartData, this.type, this.connection,
      {super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ShowMoneyFrame(type, 0, balanceValue),
        SizedBox(
            height: 360.h,
            child: connection == false ? null : ChartPie(chartData!)),
        CategoryDetails(type, getTranslated(context, 'Category') ?? 'Category',
            0, type == 'Income' ? green : red, Icons.category_outlined, true)
      ],
    );
  }
}

class CategoryDetails extends StatelessWidget {
  final String type, category;
  final double amount;
  final Color? color;
  final IconData icon;
  final bool forNullDetail;
  const CategoryDetails(this.type, this.category, this.amount, this.color,
      this.icon, this.forNullDetail,
      {super.key});
  @override
  Widget build(BuildContext context) {
    return Card(
        color: white,
        elevation: 3,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                color: forNullDetail
                    ? type == 'Income'
                        ? green
                        : red
                    : color,
                size: 23.sp,
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 15.w, right: 10.w),
                  child: Text(
                    category,
                    style: TextStyle(fontSize: 20.sp),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                  ),
                ),
              ),
              // attention: This widget will never overflow
              Flexible(
                flex: 0,
                child: Text(
                  // '${this.color!.red},' + '${this.color!.green},' + '${this.color!.blue},',
                  '${format(amount)} $currency',
                  style: GoogleFonts.aBeeZee(fontSize: 20.sp),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ),
              SizedBox(
                width: 10.w,
              ),
              forNullDetail
                  ? const SizedBox()
                  : Icon(
                      Icons.arrow_forward_ios,
                      size: 18.sp,
                    ),
            ],
          ),
        ));
  }
}
