import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:htd/globals.dart';

class HelpPage extends StatefulWidget {
  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  int _currentStep = 0;
  String _currentShow = 'siteAdd';
  int _totalSteps = 4;



  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    List<Step> siteAddStep = [
      Step(
        title: Text('ညာဘက်သို့ဆွဲပြီး Menu ဖွင့်ပါ'),
        content: Column(
          children: [
            Text('Operation ကိုနှိပ်ပါ'),
            GestureDetector(
              child: CachedNetworkImage(
                imageUrl:
                'https://firebasestorage.googleapis.com/v0/b/htdemployee.appspot.com/o/helpPage%2F20201130_145254.jpg?alt=media&token=063f161a-de16-425f-8fed-67dfbe29aebe',
                height:
                MediaQuery.of(context).size.height * 0.25,
              ),
              onTap: () {
                showHero(context,
                  'https://firebasestorage.googleapis.com/v0/b/htdemployee.appspot.com/o/helpPage%2F20201130_145254.jpg?alt=media&token=063f161a-de16-425f-8fed-67dfbe29aebe',
                );
              },
            ),
          ],
        ),
      ),
      Step(
        title: Text('New Site ကို နှိပ်ပါ'),
        content: Column(
          children: [
            Text('ထည့်မည့် Operator နှင့် ဆိုက် အမျိုးအစားကိုရွေးပါ '),
            GestureDetector(
              child: CachedNetworkImage(
                imageUrl:
                'https://firebasestorage.googleapis.com/v0/b/htdemployee.appspot.com/o/helpPage%2F20201130_145340.jpg?alt=media&token=32115ee9-92b3-46d3-b3e5-90be0e3fd1bb',
                height:
                MediaQuery.of(context).size.height * 0.25,
              ),
              onTap: () {
                showHero(context,
                  'https://firebasestorage.googleapis.com/v0/b/htdemployee.appspot.com/o/helpPage%2F20201130_145340.jpg?alt=media&token=32115ee9-92b3-46d3-b3e5-90be0e3fd1bb',
                );
              },
            ),
          ],
        ),
      ),
      Step(
        title: Text('ဆိုက် Data ထည့်ပါ'),
        subtitle: Column(
          children: [

          ],
        ),
        content: Column(
          children: [
            Text('Received Date Time သည် Mail ၀င်သည့် အချိန်ဖြစ်ပြီး'),
            Text('Install Date Time သည် ဆိုက် ပြီးစီသည့် အချိန်ဖြစ်'),
            Text('ဆိုက် မပြီးသေးခင် Install Date Time ကို ဖြည့်ရန်မလိုပါ'),
            Text('အချက်အလက်များ ပြည့်စုံအောင်ဖြည့်ပြီး Save နှိပ်ပါ'),
            GestureDetector(
              child: CachedNetworkImage(
                imageUrl:
                'https://firebasestorage.googleapis.com/v0/b/htdemployee.appspot.com/o/helpPage%2FScreenshot_20201130-133628.jpg?alt=media&token=dc39ed46-2c91-4834-902c-94dbdaa45cbd',
                height:
                MediaQuery.of(context).size.height * 0.25,
              ),
              onTap: () {
                showHero(context,
                  'https://firebasestorage.googleapis.com/v0/b/htdemployee.appspot.com/o/helpPage%2FScreenshot_20201130-133628.jpg?alt=media&token=dc39ed46-2c91-4834-902c-94dbdaa45cbd',
                );
              },
            ),
          ],
        ),
      ),
      Step(
        title: Text('ဆိုက်သစ် တစ်ခု ထည့် ပြီးပါပြီ'),
        content: Column(
          children: [
            GestureDetector(
              child: CachedNetworkImage(
                imageUrl:
                'https://firebasestorage.googleapis.com/v0/b/htdemployee.appspot.com/o/helpPage%2F20201130_145443.jpg?alt=media&token=b8abde28-5cd0-4a9d-b839-3bcafea36c64',
                height:
                MediaQuery.of(context).size.height * 0.25,
              ),
              onTap: () {
                showHero(context,
                  'https://firebasestorage.googleapis.com/v0/b/htdemployee.appspot.com/o/helpPage%2F20201130_145443.jpg?alt=media&token=b8abde28-5cd0-4a9d-b839-3bcafea36c64',
                );
              },
            ),
          ],
        ),
      ),
    ];

    return Scaffold(
        body: Container(
            margin: EdgeInsets.all(10),
            child: Column(children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.15,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueGrey),
                    borderRadius: BorderRadius.all(Radius.circular(15))),
                child: ListView(
                  children: [
                    FlatButton(
                      child: Text('Site Add'),
                      onPressed: () {
                        this.setState(() {
                          _currentShow = 'siteAdd';
                          _currentStep = 0;
                          _totalSteps = siteAddStep.length;
                        });
                      },
                    ),
                    FlatButton(
                      child: Text('Site Process'),
                      onPressed: () {
                        this.setState(() {
                          _currentShow = 'siteProcess';
                          _currentStep = 0;
                        });
                      },
                    ),
                    FlatButton(
                      child: Text('Map Control'),
                      onPressed: () {
                        this.setState(() {
                          _currentShow = 'mapControl';
                          _currentStep = 0;
                        });
                      },
                    )
                  ],
                ),
              ),
             Expanded(
               child: Container(
                 child: Stepper(
                        physics: ClampingScrollPhysics(),
                        //remaing stepper code
                        currentStep: _currentStep,
                        onStepContinue: () {
                          setState(() {
                            if (_currentStep < _totalSteps-1)
                            {
                              _currentStep++;
                            }
                          });
                        },
                        onStepTapped: (value) {
                          setState(() {
                            _currentStep = value;
                          });
                        },
                        steps:
                     _currentShow=='siteAdd'?
                         siteAddStep:
                         []
                      ),
               ),
             ),
            ]
    )
    )
    );
  }
}
