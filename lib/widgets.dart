import 'package:flutter/material.dart';
import 'package:todo/database.dart';

class Global {
  static final AppDatabase _database = AppDatabase();

  static AppDatabase get database => _database;
}

/// the TextField at the bottom of the page.
class BottomInput extends StatefulWidget {
  const BottomInput(
      {super.key, required this.textSuggestion, required this.onSubmit});
  final String textSuggestion;

  ///
  final Function(String) onSubmit;

  @override
  State<BottomInput> createState() => _BottomInputState();
}

class _BottomInputState extends State<BottomInput> {
  final TextEditingController _textController = TextEditingController();
  //TODO init and dispose
  late FocusNode _textFieldFocus;

  @override
  void initState() {
    super.initState();
    _textFieldFocus = FocusNode();
  }

  @override
  void dispose() {
    _textFieldFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
      ),
      child: Row(
        children: [
          Expanded(
              child: Container(
            padding: const EdgeInsets.only(left: 10.0),
            //textfield
            child: TextField(
              maxLength: 255,
              controller: _textController, // Attach the TextEditingController
              focusNode: _textFieldFocus, // Attach the FocusNode
              canRequestFocus: true,
              decoration: const InputDecoration.collapsed(
                hintText: "Add to list",
              ),
              onSubmitted: (value) {
                onSubmit(value, context);
              },
              buildCounter: (BuildContext context,
                  {int? currentLength, int? maxLength, bool? isFocused}) {
                // Returning null hides the counter
                return null;
              },
            ),
          )),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              onSubmit(_textController.text, context);
            },
          ),
        ],
      ),
    );
  }

  void onSubmit(String value, BuildContext context) {
    widget.onSubmit(value);
    //TODO why does it keep focusing when I click on something else?
    // Keep focus on the TextField
    // Check if the text field has focus before refocusing
    if (FocusScope.of(context).focusedChild == _textController) {
      FocusScope.of(context).requestFocus(_textFieldFocus);
    }
    // Clear the TextField
    _textController.clear();
    FocusScope.of(context).requestFocus(new FocusNode());
  }
}

class StreamDropDownButton extends StatelessWidget {
  final Profile? currentProfile;
  final Stream<List<Profile>> profileStream;
  final Function(String) onChanged;

  StreamDropDownButton({
    required this.currentProfile,
    required this.profileStream,
    required this.onChanged,
  });

  /// Asynchronously builds a DropdownButton with profiles from the database.
  /// Handles loading, errors, and allows the user to select a profile.
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: profileStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            currentProfile == null) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return DropdownButton<String>(
            value: currentProfile!.name,
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            onChanged: (String? value) {
              onChanged(value!);
            },
            items:
                snapshot.data?.map<DropdownMenuItem<String>>((Profile value) {
                      return DropdownMenuItem<String>(
                        value: value.name,
                        child: Text(value.name),
                      );
                    }).toList() ??
                    [],
          );
        }
      },
    );
  }
}

//TODO can I reuse instead of having two separate ones?
ListView TodoListList(
    AsyncSnapshot<dynamic> snapshot, IconData icon, Function onTapCallback) {
  return ListView.builder(
    itemCount: snapshot.data?.length ?? 0,
    itemBuilder: (BuildContext context, int index) {
      return ListTile(
        leading: Icon(icon),
        //use subtitle to use normalBody
        subtitle: Text(snapshot.data![index].name),
        onTap: () {
          onTapCallback(snapshot.data![index]);
        }, // Handle your onTap here.
      );
    },
  );
}
