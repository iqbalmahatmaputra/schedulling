import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schedulling/app/data/models/medicine.dart';
import 'package:schedulling/app/data/models/notification.dart' as notif;
import 'package:schedulling/app/helper/db_helper.dart';
import 'package:schedulling/app/modules/home/controllers/home_controller.dart';
import 'package:schedulling/app/utils/notification_api.dart';

class AddScheduleController extends GetxController {
  late TextEditingController nameController;
  late TextEditingController frequencyController;
  final List<TextEditingController> timeController =
      [TextEditingController()].obs;

  var db = DbHelper();
  final frequency = 0.obs;

  HomeController homeController = Get.put(HomeController());

  @override
  void onInit() {
    super.onInit();
    NotificationApi.init();

    nameController = TextEditingController();
    frequencyController = TextEditingController();
  }

  void add(String name, int frequency) async {
    await db.insertMedicine(Medicine(name: name, frequency: frequency));

    var lastMedicineId = await db.getLastMedicineId();

    for (int i = 1; i <= frequency; i++) {
      await db.insertNotification(notif.Notification(
          idMedicine: lastMedicineId, time: timeController[i].text));
    }

    List<notif.Notification> notifications =
        await db.getNotificationsByMedicineId(lastMedicineId);

    for (var element in notifications) {
      NotificationApi.scheduledNotification(
        id: element.id!,
        title: "Waktunya minum obat $name",
        body: "Minum obat agar cepat sembuh :)",
        payload: name,
        scheduledDate: TimeOfDay(
          hour: int.parse(element.time.split(':')[0]),
          minute: int.parse(element.time.split(':')[1]),
        ),
      ).then((value) => print("notif ${element.id} scheduled"));
    }

    homeController.getAllMedicineData();
    Get.back();
  }
}
