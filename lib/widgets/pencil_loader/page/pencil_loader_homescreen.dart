import 'package:drighna_ed_tech/widgets/pencil_loader/page/pencil_loader.dart';
import 'package:flutter/material.dart';



class PencilLoaderProgressBar extends StatefulWidget {
  const PencilLoaderProgressBar({super.key});

  @override
  State<PencilLoaderProgressBar> createState() => _PencilLoaderProgressBarState();
}

class _PencilLoaderProgressBarState extends State<PencilLoaderProgressBar> {
  int currentDuration = 5;
  @override
  Widget build(BuildContext context) {
    return  Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Center(
            child: SizedBox(
              height: 120,
              width: 120,
              child: PencilLoader(duration: currentDuration),
            ),
          ),
          const Spacer(),
        
       
        ],
      );
  }

 
}
