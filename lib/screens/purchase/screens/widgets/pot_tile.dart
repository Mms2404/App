import 'package:app/constants/colors.dart';
import 'package:app/screens/purchase/models/models.dart';
import 'package:flutter/material.dart';

class PotTile extends StatelessWidget {
  final Pots pot;
  final void Function()? onTap;

  const PotTile({super.key, required this.pot, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Card(
        elevation: 5,
        child: Container(
          height: 220,
          width: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only (
                  left: 5,
                  top: 5 ),
                child: Container(
                  height: 150,
                  width: 190,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(pot.imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Divider(thickness: 1, color: AppColors.palegreen , indent: 10, endIndent: 10,),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(pot.name, style: TextStyle(fontSize: 16)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(pot.material, style: TextStyle(fontSize: 16, color: AppColors.palegreen)),
              ),
              Padding(
                padding:  const EdgeInsets.symmetric(horizontal: 5),
                child: Text("Height : ${pot.height}  ,  Width : ${pot.width}" , style: TextStyle(fontSize: 14 , color: AppColors.grey),),
              ),

              Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  onTap: onTap,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("  Price : Rs.${pot.price}"),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.black,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                          ),
                        ),
                        child: Icon(Icons.add, color: AppColors.palegreen, size: 16),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
