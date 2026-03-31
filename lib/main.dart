import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(const MyApp());
}

/// ================= MODELS =================

class Booking {
  final String sport;
  final DateTime date;
  final String time;

  Booking({required this.sport, required this.date, required this.time});
}

class SavedCard {
  final String number;
  final String name;
  final String date;

  SavedCard({
    required this.number,
    required this.name,
    required this.date,
  });
}

class PriceService {
  int getPrice() => 20;
}

/// ================= APP =================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BookingPage(),
    );
  }
}

/// ================= PAGE =================

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final PriceService priceService = PriceService();

  DateTime selectedDate = DateTime.now();
  String selectedSport = "Squash";
  String? selectedTime;

  List<Booking> bookings = [];
  List<SavedCard> savedCards = [];

  final List<String> sports = ["Squash", "Tennis", "Padel"];
  final List<String> hours =
  List.generate(15, (i) => "${6 + i}:00");

  /// ADD BOOKING
  void addBooking() {
    if (selectedTime == null) return;

    setState(() {
      bookings.add(Booking(
        sport: selectedSport,
        date: selectedDate,
        time: selectedTime!,
      ));
    });
  }

  /// DELETE BOOKING
  void removeBooking(int index) {
    setState(() {
      bookings.removeAt(index);
    });
  }

  /// ================= PAYMENT =================

  void openPaymentDialog() {
    final cardController = TextEditingController();
    final nameController = TextEditingController();
    final dateController = TextEditingController();
    final cvvController = TextEditingController();

    bool saveCard = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text("Payment"),
              content: SingleChildScrollView(
                child: Column(
                  children: [

                    /// 💾 SAVED CARDS
                    if (savedCards.isNotEmpty)
                      Column(
                        children: savedCards.map((card) {
                          return ListTile(
                            leading: const Icon(Icons.credit_card),
                            title: Text(card.number),
                            subtitle: Text(card.name),
                            onTap: () {
                              cardController.text = card.number;
                              nameController.text = card.name;
                              dateController.text = card.date;
                            },
                          );
                        }).toList(),
                      ),

                    const SizedBox(height: 10),

                    /// CARD
                    TextField(
                      controller: cardController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        MaskedCardFormatter(),
                      ],
                      decoration: const InputDecoration(
                        labelText: "Card Number",
                        hintText: "xxxx xxxx xxxx xxxx",
                      ),
                    ),

                    /// NAME
                    TextField(
                      controller: nameController,
                      decoration:
                      const InputDecoration(labelText: "Name"),
                    ),

                    /// DATE + CVV
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: dateController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              DateFormatter(),
                            ],
                            decoration:
                            const InputDecoration(labelText: "MM/YY"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: cvvController,
                            keyboardType: TextInputType.number,
                            maxLength: 3,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration:
                            const InputDecoration(labelText: "CVV"),
                          ),
                        ),
                      ],
                    ),

                    /// SAVE CARD
                    Row(
                      children: [
                        Checkbox(
                          value: saveCard,
                          onChanged: (value) {
                            setStateDialog(() {
                              saveCard = value!;
                            });
                          },
                        ),
                        const Text("Save Card"),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);

                    /// SAVE MULTIPLE CARDS
                    if (saveCard &&
                        cardController.text.isNotEmpty) {
                      setState(() {
                        savedCards.add(
                          SavedCard(
                            number: cardController.text,
                            name: nameController.text,
                            date: dateController.text,
                          ),
                        );
                      });
                    }

                    addBooking();
                  },
                  child:
                  Text("Pay \$${priceService.getPrice()}"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// ================= UI =================

  Widget buildSports() {
    return Row(
      children: sports.map((sport) {
        bool selected = selectedSport == sport;

        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                selectedSport = sport;
              });
            },
            child: AnimatedScale(
              duration: const Duration(milliseconds: 200),
              scale: selected ? 1.05 : 1,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.all(5),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF6D9773)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text(
                    sport,
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget buildHours() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: hours.length,
      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.5,
      ),
      itemBuilder: (context, index) {
        final h = hours[index];
        final selected = selectedTime == h;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedTime = h;
            });
          },
          child: AnimatedScale(
            scale: selected ? 1.1 : 1,
            duration: const Duration(milliseconds: 200),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF6D9773)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(h),
            ),
          ),
        );
      },
    );
  }

  Widget buildBookings() {
    return Column(
      children: bookings.asMap().entries.map((entry) {
        int i = entry.key;
        Booking b = entry.value;

        return ListTile(
          title: Text(
              "${b.sport} - ${b.date.toString().split(" ")[0]} - ${b.time}"),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => removeBooking(i),
          ),
        );
      }).toList(),
    );
  }

  /// ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        title: const Text("Court Booking"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020),
              lastDay: DateTime.utc(2030),
              focusedDay: selectedDate,
              selectedDayPredicate: (day) =>
                  isSameDay(day, selectedDate),
              onDaySelected: (day, _) {
                setState(() {
                  selectedDate = day;
                });
              },
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),

            const SizedBox(height: 20),

            buildSports(),
            const SizedBox(height: 20),
            buildHours(),

            const SizedBox(height: 20),

            GestureDetector(
              onTap: openPaymentDialog,
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF6D9773),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    "Confirm",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            buildBookings(),
          ],
        ),
      ),
    );
  }
}

/// ================= FORMATTERS =================

class MaskedCardFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue) {
    String digits = newValue.text.replaceAll(' ', '');

    if (digits.length > 16) return oldValue;

    String result = '';

    for (int i = 0; i < digits.length; i++) {
      if (i % 4 == 0 && i != 0) result += ' ';
      result += digits[i];
    }

    return TextEditingValue(
      text: result,
      selection:
      TextSelection.collapsed(offset: result.length),
    );
  }
}

class DateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue) {
    String digits = newValue.text.replaceAll('/', '');

    if (digits.length > 4) return oldValue;

    String result = '';

    for (int i = 0; i < digits.length; i++) {
      if (i == 2) result += '/';
      result += digits[i];
    }

    return TextEditingValue(
      text: result,
      selection:
      TextSelection.collapsed(offset: result.length),
    );
  }
}