import 'package:app/constants/colors.dart';
import 'package:app/screens/purchase/models/models.dart';
import 'package:flutter/material.dart';

class SucculentTile extends StatelessWidget {
  final Succulents succulent;
  final void Function()? onTap;
  SucculentTile({super.key , required this.succulent , required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Card(
        elevation: 5,
        child: Container(
          margin: EdgeInsets.only(left : 10),
          height: 260,
          width: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10)
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 10,
                  right: 10,
                ),
                child: Container(
                  width: 250,
                  height: 170,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: NetworkImage(succulent.imagePath),
                      fit: BoxFit.cover
                    )
                  ),),
              ),
              Divider(thickness: 1,color: AppColors.palegreen,endIndent: 10,),
              Text(succulent.name, style: TextStyle( fontSize: 15),),
              Text(succulent.description , style: TextStyle(color: AppColors.grey),),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('PRICE :${succulent.price}', style: TextStyle( fontSize: 15),),
                  GestureDetector(
                    onTap: onTap ,
                    child: Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: AppColors.black , 
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10)
                      )),
                      child: Icon(Icons.add , color: AppColors.palegreen,)
                    ),
                  ),
                ],
              )
            ],
          ),
        
        ),
      ),
    );
  }
}