import 'package:code_crafters/services/get_courses.dart';
import 'package:dev_icons/dev_icons.dart';
import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';

class HtmlVieww extends StatefulWidget {
  @override
  _HtmlViewwState createState() => _HtmlViewwState();
}

class _HtmlViewwState extends State<HtmlVieww> {
  int selectedModuleIndex = 0; // Index du module sélectionné, 0 par défaut
  Future<Map<String, dynamic>?>? courseFuture;

  @override
  void initState() {
    super.initState();
    courseFuture = getHtmlCourseFromFirestore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: FutureBuilder<Map<String, dynamic>?>(
        future: courseFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              final courseData = snapshot.data!;
              final modules = courseData['modules'] as List<dynamic>? ?? [];
              final selectedModule = modules[selectedModuleIndex];
              final lessons = selectedModule['lesson'] as List<dynamic>? ?? [];

              return Column(
                children: [
                  GestureDetector(
                    onTap: () => showModulesBottomSheet(context, modules),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.book_online_outlined),
                        Container(
                          decoration: const BoxDecoration(),
                          padding: EdgeInsets.all(20),
                          child: Flexible(
                            child: Text(
                              'Module: ${selectedModule['title']}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: lessons.length,
                      itemBuilder: (context, index) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          height: 200,
                          child: TimelineTile(
                            isFirst: index == 0,
                            isLast: index == lessons.length - 1,
                            alignment: TimelineAlign.start,
                            lineXY: 0.1,
                            beforeLineStyle: const LineStyle(
                                thickness: 4, color: Colors.deepPurple),
                            indicatorStyle: IndicatorStyle(
                              width: 35,
                              color: Colors.grey,
                              iconStyle: IconStyle(
                                  iconData: Icons.lock, color: Colors.white),
                            ),
                            endChild: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.11,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.grey,
                                            spreadRadius: 2,
                                            blurRadius: 0,
                                            offset: Offset(0, 2),
                                          )
                                        ]),
                                    child: ListTile(
                                      leading: Icon(DevIcons.html5Plain,
                                          color: Colors.orange),
                                      trailing: Icon(
                                        Icons.book_rounded,
                                        color: Colors.deepPurple,
                                      ),
                                      title: Text(
                                        lessons[index]['title'],
                                      ),
                                      titleTextStyle: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ))),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            } else {
              return const Center(
                  child: Text('Aucune donnée de cours disponible.'));
            }
          } else if (snapshot.hasError) {
            return const Center(
                child: Text('Erreur lors du chargement des données'));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  void showModulesBottomSheet(BuildContext context, List<dynamic> modules) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView.builder(
          itemCount: modules.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(modules[index]['title']),
              onTap: () {
                setState(() {
                  selectedModuleIndex = index;
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }
}
