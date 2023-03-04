import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:labtest/Auth/sign_up_screen.dart';
import 'package:labtest/recipieModel.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 02',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'My Recipie List'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  @override
  void initState(){
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
         Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context) => const SignUpScreen(),
            ),
          );
      } else {
        print('User is signed in!');
        print("User ${user.toString()}");
      }
  });
  }
  
  //create list to store todo list 
  //List<RecipieModel> recipieList = [];
  int recepieListlength = 0;
  final db = FirebaseFirestore.instance;

  // create controllers to handle inputs
  TextEditingController taskController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  // create a boolean variable to handle input fields
  bool viewInputfields = false;

  // create a function to add new todo
  void _addnewToDo(String title , String description ) async {

    final docRef = db.collection('recipieList').doc();
    docRef.set(RecipieModel(recepieListlength,title, description , ["bread","dhal"]).toJson()).then(
      (value) => Fluttertoast.showToast(msg:"Recipie added successfully!"),
      onError: (e) => print("Error adding Recipie: $e"));

    //recipieList.add(RecipieModel(recepieListlength,task, name, 3));
    recepieListlength++;
    setState(() {});
  }

  // create a function to remove todo
  void _removeToDo(dynamic docID,RecipieModel todo) {
        print(todo.id);
        db.collection('recipieList').doc(docID.toString()).delete().then(
            (value) => Fluttertoast.showToast(msg:"Recipie deleted Successfully!"),
            onError: (e) => print("Error deleting Recipie: $e"));
    setState(() {
      //print("todo list before delete ${recipieList.toList()}");
      //recipieList.removeAt(index);
      recepieListlength--;
      //print("todo list after delete ${recipieList.toList()}");
    });
  }

  void _changeRecipe(dynamic docID,RecipieModel recipie) {
        recipie.description = "Updated";
        db.collection('recipieList').doc(docID.toString()).set(recipie.toJson()).then(
            (value) => Fluttertoast.showToast(msg:"Recipie updated Successfully!"),
            onError: (e) => print("Error updating Recipie: $e"));
    setState(() {
      //print("todo list before delete ${recipieList.toString()}");
      //recipieList[index].status = 1;
      //print("todo list after delete ${recipieList.toString()}");
    });
  }

  Future getRecepieLists() async {
        return db.collection("recipieList").get();
    }

    Future<String?> signOut() async {
        try {
          await FirebaseAuth.instance.signOut();
          Fluttertoast.showToast(msg:"Sign Out Successfull");
           Navigator.push(
              context, 
              MaterialPageRoute(
                builder: (context) => const SignUpScreen(),
              ),
            );
          return null;
        } on FirebaseAuthException catch (ex) {
          return "${ex.code}: ${ex.message}";
        }
      }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
              IconButton(
                onPressed: (){
                  signOut();
                },
                tooltip: 'Sign Out',
                icon: const Icon(Icons.logout_outlined)
              ), 
        ],
      ),
      body: Center(
        child: Stack(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //show and hide input fields according to the variable value
            if(viewInputfields)
            Container(
              padding: const EdgeInsets.all(20),
              height: 250,
              width: MediaQuery.of(context).size.width * 0.9 ,              
              decoration: BoxDecoration(                
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  const Center(
                    child: Text(
                      'Add New Recipie',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,                      
                      ),
                    ),                  
                  ),
                  TextField(
                    controller: taskController,
                    decoration: const InputDecoration(
                      hintText: 'Enter Title',
                    ),
                  ),
                  const SizedBox(height: 20,),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      hintText: 'Enter Description',
                    ),
                  ),
                  const SizedBox(height: 20,),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () {
                          _addnewToDo(taskController.text, nameController.text);
                          taskController.clear();
                          nameController.clear();
                          setState(() {
                            viewInputfields = false;
                          });
                        }, 
                        child: const Text('Add')                  
                    ),
                  )
                ],
              ),
            ),
            if(!viewInputfields) 
           FutureBuilder(
              future: getRecepieLists(),
              builder: ((context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.data == null) {
                  return const SizedBox();
                }

                if (snapshot.data!.docs.isEmpty) {
                  print("List ${snapshot.data.docs}");
                  return const SizedBox(
                    child: Center(
                        child:
                            Text("No Recipies")),
                  );
                }

                if (snapshot.hasData) {
                  List<Map<dynamic,dynamic>> recipieList = [];

                  for (var doc in snapshot.data!.docs) {
                    final todo = RecipieModel.fromJson(doc.data() as Map<String, dynamic>);
                    Map<dynamic,dynamic> map = {
                      "docId":doc.id,
                      "todo":todo
                      };
                    recipieList.add(map);
                  }

                  return ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: recipieList.length,
                    itemBuilder: (context, index) {
                      return  Card(
                          child: ListTile(
                            title: Text(recipieList[index]["todo"].title!),
                            subtitle: Text(recipieList[index]["todo"].description!),                      
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip : "Press to mark complete",
                                  onPressed: () {
                                    _changeRecipe(recipieList[index]["docId"],recipieList[index]["todo"]);
                                  }, 
                                  icon: const Icon(
                                    Icons.update_rounded,
                                    color: Colors.green,
                                  ),
                                ),
                                IconButton(
                                  tooltip : "Press to delete Task",
                                  onPressed: () {
                                    _removeToDo(recipieList[index]["docId"],recipieList[index]["todo"]);
                                  }, 
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,)
                                ),
                              ],
                              )
                          ),
                        );
                    },
                  );
                }

                return const SizedBox();
              }),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          setState(() {
            viewInputfields = true;
          });
        },
        tooltip: 'Add Recipie',
        child: const Icon(Icons.add),
      )
    );
  }
}
