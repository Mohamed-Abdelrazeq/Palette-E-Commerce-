import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multivender_ecommerce_app/Controllers/UserCredController.dart';
import 'package:multivender_ecommerce_app/Models/OrderModel.dart';
import 'package:multivender_ecommerce_app/Models/ProductModel.dart';
import 'package:multivender_ecommerce_app/Models/StatusModel.dart';
import 'package:multivender_ecommerce_app/Models/UserModel.dart';
import 'package:multivender_ecommerce_app/Views/Component/Header.dart';
import 'package:multivender_ecommerce_app/Views/Component/MainButton.dart';
import 'package:multivender_ecommerce_app/Views/Component/MainCard.dart';
import 'package:multivender_ecommerce_app/Views/Component/MyTextField.dart';
import 'package:provider/provider.dart';

import '../MyColors.dart';
class CartPage extends StatefulWidget {
  CartPage({
    @required this.pageController,
});

  final PageController pageController;
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {

  bool _phoneNumberCheck(BuildContext context){
    var mobile = Provider.of<UserCredController>(context,listen: false).userModel.mobile;
    if(mobile == "" || mobile ==null){
      return false;
    }else{
      return true;
    }
  }

  TextEditingController _searchTextController;

  @override
  Widget build(BuildContext context) {
    double statusBar = MediaQuery.of(context).padding.top;
    List<ProductModel> cartData = Provider.of<UserCredController>(context).userModel.cart;
    return Scaffold(
      backgroundColor: bgColor,
      body: Padding(
        padding: EdgeInsets.only(top: statusBar.h,),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 28.w,right: 28.w),
                child: Column(
                  children: [
                    Header(header: "Cart",),
                    MyTextFiled(textController: _searchTextController, myIcon: Icons.search, hint: "Search",focus: false,),
                    SizedBox(height: 22.h,),
                  ],
                ),
              ),
              Stack(
                alignment: Alignment.bottomCenter,
                children:[
                  Container(
                  height: 410.h,
                  width: 375.w,
                  padding: EdgeInsets.only(bottom: 9.h,),
                  child: GridView.count(
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    padding: EdgeInsets.only(left: 28.w,right: 28.w,bottom: 100.h),
                    children: List.generate(cartData.length, (index) {
                      return MainCard(marginRight: 0,productModel: cartData[index],);
                    }),
                  ),
                ),
                  Positioned(
                    bottom: 30.h,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 28.w),
                      child: MainButton(text: "Checkout", btnFunction: ()async{
                        bool phoneCheckResults = _phoneNumberCheck(context);
                        if(!phoneCheckResults){
                          Navigator.pushNamed(context, "/AddPhoneNumber");
                        }else {
                          double totalPrice = 0.0;
                          cartData.forEach((element) {
                            totalPrice = element.price + totalPrice;
                          });
                          UserModel userModel = Provider.of<UserCredController>(context,listen: false).userModel;
                          await OrderModel(
                            user: Provider.of<UserCredController>(context,listen: false).userModel,
                            status: StatusModel().waiting,
                            price: totalPrice,
                            orderingDate: DateTime.now(),
                            products: cartData
                          ).addOrder();
                          await userModel.cleanCart();
                          widget.pageController.animateToPage(0, duration: Duration(milliseconds: 300), curve: Curves.easeIn);
                        }
                      }),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
