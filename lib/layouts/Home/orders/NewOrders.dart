import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nava_tech/helpers/constants/base.dart';
import 'package:nava_tech/helpers/customs/EmptyBox.dart';
import 'package:nava_tech/helpers/customs/Loading.dart';
import 'package:nava_tech/helpers/models/NewOrdersModel.dart';
import 'package:nava_tech/layouts/Home/orders/OrderItem.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class NewOrders extends StatefulWidget {

  @override
  _NewOrdersState createState() => _NewOrdersState();
}

class _NewOrdersState extends State<NewOrders> {

  @override
  void initState() {
    getNewOrders();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return

      loading ?MyLoading():


      newOrdersModel.data.data.length == 0 ?
          EmptyBox(
            title: tr("noOrders"),
            widget: Container(),
          )
          :
      ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 15),
      itemCount: newOrdersModel.data.data.length,
        itemBuilder: (c,i){
      return OrderItem(
        id: newOrdersModel.data.data[i].id,
        name: newOrdersModel.data.data[i].name,
        img: newOrdersModel.data.data[i].avatar,
        location: newOrdersModel.data.data[i].address,
        status: newOrdersModel.data.data[i].status,
        orderNum: newOrdersModel.data.data[i].orderNum,
        date: newOrdersModel.data.data[i].date,
        time: newOrdersModel.data.data[i].time,
        from: newOrdersModel.data.data[i].createdDate,
      );
    });
  }



  bool loading = true;
  NewOrdersModel newOrdersModel = NewOrdersModel();
  Future getNewOrders() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final url = Uri.https(URL, "api/new-orders");
    try {
      final response = await http.post(url,
        headers: {"Authorization": "Bearer ${preferences.getString("token")}"},
        body: {
          "lang": preferences.getString("lang"),
        },
      ).timeout(Duration(seconds: 10), onTimeout: ()=>throw 'no internet please connect to internet');
      final responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        setState(() => loading = false);
        print(responseData);
        if (responseData["key"] == "success") {
          newOrdersModel = NewOrdersModel.fromJson(responseData);
        } else {
          Fluttertoast.showToast(msg: responseData["msg"]);
        }
      }
    } catch (e, t) {
      print("error $e" + " ==>> track $t");
    }
  }


}
