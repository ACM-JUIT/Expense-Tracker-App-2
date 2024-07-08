import 'package:basecode/components/add_expense_tile.dart';
import 'package:basecode/components/my_button.dart';
import 'package:basecode/model/expense_model.dart';
import 'package:basecode/services/add_expense/repository/expense_repository.dart';
import 'package:basecode/services/add_expense/screen/category_creation.dart';
import 'package:basecode/services/auth/repository/auth_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController expenseController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController datecontroller = TextEditingController();
  final TextEditingController categorycontroller = TextEditingController();

  List<String> myIcons = [
    'entertainment',
    'food',
    'home',
    'pet',
    'shopping',
    'tech',
    'travel'
  ];

  void pickDate() async {
    DateTime? newdate = await showDatePicker(
      initialDate: DateTime.now(),
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ),
    );
    if (newdate != null) {
      setState(() {
        datecontroller.text = DateFormat('dd/MM/yyyy').format(newdate);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    datecontroller.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
  }

  @override
  void dispose() {
    super.dispose();
    expenseController.dispose();
    nameController.dispose();
    descriptionController.dispose();
    categorycontroller.dispose();
    datecontroller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthRepository>().currentUid;
    final id = Uuid().v1();
    print("add_expense $id");
    DateTime? newDate;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFFF0F0F2),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF0F0F2),
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back),
          ),
          title: Text(
            "Expenses",
            style: TextStyle(
              color: const Color(0xFF322F50),
              fontWeight: FontWeight.w600,
              fontSize: 25,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextFormField(
                  controller: expenseController,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    prefixIcon: TextButton(
                      onPressed: () {},
                      child: Text("₹"),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  readOnly: true,
                  onTap: () {},
                  controller: categorycontroller,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      onPressed: () {
                        var category = getCategoryCreation(context, id);
                        print(category);
                      },
                      icon: Icon(
                        FontAwesomeIcons.plus,
                        size: 18,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    hintText: "Category",
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    hintStyle: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  textAlignVertical: TextAlignVertical.center,
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: datecontroller,
                  readOnly: true,
                  onTap: () async {
                    pickDate();
                  },
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    hintText: "Date",
                    hintStyle: TextStyle(
                      color: Colors.grey,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () async {
                        newDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)));

                        if (newDate != null) {
                          setState(() {
                            datecontroller.text =
                                DateFormat('dd/MM/yyyy').format(newDate!);
                            // selectDate = newDate;
                          });
                        }
                      },
                      icon: Icon(Icons.date_range_rounded),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                AddExpenseTile(
                  controller: descriptionController,
                  hint: "Description",
                  onTap: () {},
                ),
                const SizedBox(height: 120),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30.0, vertical: 30),
                  child: MyButton(
                    text: "Add Expense",
                    onTap: () async {
                      final expense = Expense(
                        amount: int.parse(expenseController.text),
                        category: await context
                            .read<ExpenseRepository>()
                            .getCategory(uid, id),
                        date: newDate ?? DateTime.now(),
                        id: id,
                        description: descriptionController.text,
                      );
                      context
                          .read<ExpenseRepository>()
                          .addExpense(uid, expense, context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Expense Added!!!!",
                          ),
                        ),
                      );
                    },
                    color: const Color(0xFF322F50),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
