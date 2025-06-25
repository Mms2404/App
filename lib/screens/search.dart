import 'package:app/constants/colors.dart';
import 'package:app/screens/actions/gemini.dart';
import 'package:app/screens/actions/youtube.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController controller = TextEditingController();
  String response = '';
  List<dynamic> videos = [];
  bool isLoading = false; 
  

  Future<void> sendPrompt() async {
    final prompt = controller.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      isLoading = true;
      response = '';
    });

    try {
      final result1 = await geminiSearch(prompt);
      final result2 = await youtubeSearch(prompt);
      setState(() {
        response = result1;
        videos = result2;
      });
    } catch (e) {
      setState(() {
        response = "Error: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 75,),
              TextField(
                cursorColor: AppColors.palegreen,
                controller: controller,
                decoration: InputDecoration(
                  hintText: "Search and press ENTER",
                  enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.palegreen, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.palegreen, width: 3),
                ),
                ),
                onSubmitted: (_) {
                  sendPrompt();
                },
              ),
              SizedBox(height: 20),
              isLoading
                  ? Text("Searching...")
                  : response.isNotEmpty
                    ? SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                              
                          Text(
                            " SEARCH RESULTS ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                              
                          SizedBox(height: 10),
                              
                          Container(
                            height: 400,
                            width: 500,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border : Border.all( color: AppColors.palegreen , width: 3)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: SingleChildScrollView(
                                child: MarkdownBody(
                                  data: response,
                                  styleSheet: MarkdownStyleSheet(
                                    h2: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    p: TextStyle(fontSize: 14),
                                    listBullet: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                            ),
                          ),
                              
                          SizedBox(height: 10,),
                          Text(
                            " VIDEOS ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10,),
                          
                          SizedBox(
                            height: 500,
                            width: 500,
                            child: ListView.builder(
                              itemCount: videos.length,
                              itemBuilder: (context , index){
                                final video = videos[index];
                                return ListTile(
                                  title: Text(video['snippet']['title']),
                                  subtitle: Text(video['snippet']['description']),
                                  leading: Image.network(video['snippet']['thumbnails']['default']['url']),
                                  onTap:(){},
                                );
                              }),
                          )
                        ],
                      ),
                    )
                    : Container(),
          
            ],
          ),
        ),
      ),
    );
  }
}
