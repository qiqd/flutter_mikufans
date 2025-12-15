import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mikufans/component/media_card.dart';
import 'package:mikufans/entity/work.dart';
import 'package:mikufans/service/impl/aafun.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final AafunParser _parser = AafunParser();
  String _keyword = "";
  bool _isSearching = false;
  List<Work> _medias = List.empty();
  void searchHandle(Function(String) onMssage) {
    if (_keyword.isEmpty) {
      onMssage("关键字不能为空");
      return;
    }

    _isSearching = true;
    _parser
        .fetchSearch(_keyword, 1, 10, (err) {})
        .then((value) {
          setState(() {
            _medias = value;
          });
          if (value.isEmpty) onMssage("没有任何结果");
        })
        .catchError((onError) {
          onMssage(onError);
        })
        .whenComplete(() => _isSearching = false);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SearchBar(
                elevation: const WidgetStatePropertyAll(0),
                surfaceTintColor: const WidgetStatePropertyAll(
                  Colors.transparent,
                ),
                overlayColor: const WidgetStatePropertyAll(Colors.transparent),
                hintText: '输入关键字搜索 ',
                trailing: [
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      searchHandle((mssage) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(mssage, textAlign: TextAlign.center),
                          ),
                        );
                      });
                    },
                  ),
                ],
                onChanged: (value) => _keyword = value,
                onSubmitted: (value) {
                  searchHandle((mssage) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(mssage)));
                  });
                },
              ),
            ),
            SizedBox(height: 6),
            Expanded(
              child: _isSearching
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _medias.length,
                      itemBuilder: (content, index) {
                        return MediaCard(
                          height: 220,
                          media: Work(
                            id: _medias[index].id,
                            cover: _medias[index].cover,
                            titleCn: _medias[index].titleCn,
                            title: _medias[index].title,
                            status: _medias[index].status,
                            type: _medias[index].type,
                            airdate: _medias[index].airdate,
                          ),
                          onTap: (media) {
                            print(media.toJson());
                            content.push('/detail', extra: media.id);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
