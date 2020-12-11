import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:shared_preferences/shared_preferences.dart';


class PlayChess extends StatefulWidget {
  @override
  _PlayChessState createState() => _PlayChessState();
}

class _PlayChessState extends State<PlayChess> {
  String me;
  ChessBoardController cbCtrl= new ChessBoardController();

  Future<void> getData() async
  {
    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {
      me = sp.getString('currentUser');
    });
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: new Scaffold(
        body: Column(
          children: [
            Expanded(
                child: Container(
                  child: FlatButton(
                    child: Text('Move'),
                    onPressed: () {
                      cbCtrl.makeMove('a2', 'a3');
                    },
                  ),

            )),
            Container(
              child: ChessBoard(
                size: MediaQuery.of(context).size.width*0.9,
                chessBoardController: cbCtrl,
                boardType: BoardType.orange,
                whiteSideTowardsUser: true,
                enableUserMoves: true,
                onMove: (move) {
                },
                onCheckMate: (color) {

                },
                onDraw: () {
                  print("DRAW!");
                },
              ),
            ),
            Expanded(child: Container(

            )),
          ],
        ),
      ),
    );
  }
}
