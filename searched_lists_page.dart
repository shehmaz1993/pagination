import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app_with_flutter/business%20logics/searched_data_model_class.dart';
import 'package:quran_app_with_flutter/view/loading_page.dart';
import 'package:quran_app_with_flutter/view/search_ui.dart';
import 'package:quran_app_with_flutter/view/searched_ayat_list.dart';
import 'package:quran_app_with_flutter/view/verses_of_surah_with_words.dart';
import 'package:quran_app_with_flutter/view/widget_factory/dialog_box.dart';
import 'package:quran_app_with_flutter/view/widget_factory/small_container.dart';
import 'package:quran_app_with_flutter/view/widget_factory/top_part_of_box.dart';
import 'package:quran_app_with_flutter/view/widget_factory/translations_part_box.dart';
import 'package:quran_app_with_flutter/view/widget_factory/word_by_word_box.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../business logics/bookmark_model.dart';
import '../shared_preference_services/shared_prefs_services.dart';
import '../utils/text_style_class.dart';
import '../view_model/searched_by_words_controller/searched_by_words_controller.dart';
import '../view_model/selectable_text_controller/selectable_text_controller.dart';
import '../view_model/side_menu_controller/side_menu_controller.dart';
import 'more_details_of_selected_word.dart';

class SearchedListPage extends StatefulWidget {
  const SearchedListPage({super.key});

  @override
  State<SearchedListPage> createState() => _SearchedListPageState();
}

class _SearchedListPageState extends State<SearchedListPage> {
  bool isSearchClicked = false;
  //final ItemScrollController itemScrollController = ItemScrollController();
  //final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  final mainSideBarController = Get.put(SideMenuController());
  final BySearchedWordsController bySearchedWordsController =
  Get.put(BySearchedWordsController());
  final copyController = Get.put(SelectableTextController());
  ScrollController  _scrollController = ScrollController();


  @override
  void initState() {
    super.initState();
    bySearchedWordsController.setSelectedWord(Get.arguments[0]);
    bySearchedWordsController.setSelectedSearch(Get.arguments[1]);

     WidgetsBinding.instance.addPostFrameCallback((_) async {

       bySearchedWordsController.resetArrays();
       print('argument[0] is ${Get.arguments[0]} ');
       bySearchedWordsController.fetchTotalCount(Get.arguments[0],Get.arguments[1]);
      // bySearchedWordsController.fetchWordsDataByWord(Get.arguments[0],Get.arguments[1]);
       // Add a listene
       /*bySearchedWordsController.scrollController.addListener(() {
         // Check if the user has scrolled close to the bottom
         if (bySearchedWordsController.scrollController.position.pixels >=bySearchedWordsController.scrollController.position.maxScrollExtent) {
           if (!bySearchedWordsController.isLoading.value) {
             // Trigger the next batch of data fetch
             bySearchedWordsController.fetchWordsDataByWord(Get.arguments[0], Get.arguments[1]);
           }
         }
       });*/



     }

    );
    mainSideBarController.setValueOfShowingWordMeaning(SharedPrefsServices.getBoolData('wordbyword')??true);

  }
  @override
  void dispose() {
    print('dispose');
    bySearchedWordsController.dispose();
    _scrollController.dispose();
    super.dispose();


   // bySearchedWordsController.dispose();
    //mainSideBarController.dispose();
    //copyController.dispose();
  }
  void _scrollListener() {
    // This will be called every time the scroll position changes
    print('Scroll position: ${_scrollController.position.pixels}');
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      print('Reached the bottom of the list');
      // Load more data or perform any action here
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: Colors.transparent,
       // backgroundColor: Colors.blue.shade900,
        appBar: AppBar(
          automaticallyImplyLeading: true,
          centerTitle: true,
          title://Text('Search Results',style: TextStyle(fontSize: 22),),
          Obx(
              ()=> FittedBox(
                child: Text('Search Results(${bySearchedWordsController.chosenWord.value}): '
                    '${bySearchedWordsController.consolidatedDataList.length}',style: TextStyle(fontSize: 22),),
              ),
          ),
          actions: [
            IconButton(
                onPressed: () async {
                  bySearchedWordsController.setIsSearchClicked();
                 // String arg =
                   await showSearch(
                      context: context, delegate: CustomSearch()
                   );
                  },
                icon: Icon(
                  Icons.search,
                  color: Colors.black,
                )

            )
          ],
        ),
        body: Obx(() =>

          FutureBuilder<List<SearchedDataModel>>(
              future:bySearchedWordsController.fetchWordsDataByWord(bySearchedWordsController.chosenWord.value,bySearchedWordsController.chosenSearch.value) ,
              builder: (context,snapShot){
                return  ScrollbarTheme(
                  data: ScrollbarThemeData(
                    thumbColor: WidgetStateProperty.all(Colors.black38), // Change scrollbar color
                    trackColor: WidgetStateProperty.all(Colors.grey[300]), // Track color
                    thickness: WidgetStateProperty.all(8.0), // Scrollbar width
                  ),
                  child: Scrollbar(

                    controller: bySearchedWordsController.scrollController,
                    thickness:25.0 ,
                    thumbVisibility: true,
                    interactive: true,
                    //radius: Radius.circular(10),
                    child: ListView.separated(
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      controller:bySearchedWordsController.scrollController,
                      itemCount:snapShot.data!.length,
                      // itemScrollController: itemScrollController,
                      //itemPositionsListener: itemPositionsListener,
                      // itemScrollController: bySearchedWordsController.itemScrollController,
                      // itemPositionsListener: bySearchedWordsController.itemPositionsListener,
                      /* initialScrollIndex: bySearchedWordsController.searchState ==
                    'search_delegate' ?
                bySearchedWordsController.index.value : 0,*/
                      itemBuilder: (context, index) {

                        /* if (index == bySearchedWordsController.consolidatedDataList.length-60) {
                    if (bySearchedWordsController.isLoading.value) {
                      return CircularProgressIndicator(); // Show loading indicator
                    } else {
                      bySearchedWordsController.fetchWordsDataByWord(Get.arguments[0],Get.arguments[1]); // Trigger next batch fetch
                      return SizedBox.shrink(); // Empty widget while loading
                    }
                  }*/


                        return LayoutBuilder(builder: (context,constraint){
                          return Padding(
                            padding: index == 0
                                ? EdgeInsets.only(top: 10.0)
                                : EdgeInsets.only(top: 0.0),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      //color: Colors.white.withOpacity(0.3)
                                        gradient: const LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [Colors.white60, Colors.white24]),
                                        borderRadius: BorderRadius.circular(25),
                                        border: Border.all(
                                            width: 2, color: Colors.white30)),
                                    child: ListTile(
                                      title: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [

                                          TopPartSurahBox(
                                            surahId: snapShot.data![index].surahId!,
                                            verseId:  snapShot.data![index].verseId!,
                                            arabicName: snapShot.data![index].surahNameArabic!,
                                            englishName: snapShot.data![index].surahNameEnglish!,
                                            bengaliName: snapShot.data![index].surahNameBangla!,
                                            arabicTrans:  snapShot.data![index].arabicTranslation!,
                                            englishTrans:  snapShot.data![index].englishTranslation!,
                                            bengaliTrans:  snapShot.data![index].banglaTranslation!,
                                          ),
                                          WordByWordBoxPart(
                                              surahNameEnglish: snapShot.data![index].surahNameEnglish!,
                                              surahId: snapShot.data![index].surahId!,
                                              verseId:snapShot.data![index].verseId!,
                                              arabicWordList: snapShot.data![index].words!.arabic!,
                                              bengaliWordList: snapShot.data![index].words!.bangla!,
                                              englishWordList: snapShot.data![index].words!.english!,
                                              qWords: snapShot.data![index].qWords!,
                                              wordIds: snapShot.data![index].words!.wordIds!,
                                              arabic1:snapShot.data![index].arabicWordsData!.arabic1!,
                                              arabic2: snapShot.data![index].arabicWordsData!.arabic2!,
                                              arabic3: snapShot.data![index].arabicWordsData!.arabic3!,
                                              arabic4: snapShot.data![index].arabicWordsData!.arabic4!,
                                              arabic5: snapShot.data![index].arabicWordsData!.arabic5!,
                                              arabic: snapShot.data![index].words!.arabic!,
                                              root: snapShot.data![index].root!,
                                              lemma:snapShot.data![index].lemma!,
                                              typeEn1: snapShot.data![index].typeInfo!.typeEn1!,
                                              typeBn1: snapShot.data![index].typeInfo!.typeBn1!,
                                              typeEn2: snapShot.data![index].typeInfo!.typeEn2!,
                                              typeBn2: snapShot.data![index].typeInfo!.typeBn2!,
                                              typeEn3: snapShot.data![index].typeInfo!.typeEn3!,
                                              typeBn3: snapShot.data![index].typeInfo!.typeBn3!,
                                              typeEn4: snapShot.data![index].typeInfo!.typeEn4!,
                                              typeBn4: snapShot.data![index].typeInfo!.typeBn4!,
                                              typeEn5: snapShot.data![index].typeInfo!.typeEn5!,
                                              typeBn5: snapShot.data![index].typeInfo!.typeBn5!,
                                              bangla:snapShot.data![index].words!.bangla!,
                                              english: snapShot.data![index].words!.english!,
                                              arabicWords: snapShot.data![index].words!.arabic!,
                                              chosenWord: bySearchedWordsController.chosenWord.value
                                          ),
                                          TranslationsPartBox(
                                              englishTranslation: snapShot.data![index].englishTranslation!,
                                              banglaTranslation: snapShot.data![index].banglaTranslation!,
                                              indoTranslation: snapShot.data![index].indoTranslation!,
                                              ref1: snapShot.data![index].references!.ref1!,
                                              ref2: snapShot.data![index].references!.ref2!,
                                              ref3: snapShot.data![index].references!.ref3!,
                                              ref4: snapShot.data![index].references!.ref4!,
                                              ref5: snapShot.data![index].references!.ref5!
                                          ),

                                          const SizedBox(
                                            height: 10,
                                          )
                                        ],
                                      ),
                                      //selected:index == verseIndex ,
                                    ),
                                  ),
                                )),
                          );
                        });
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return const SizedBox(
                          height: 10,
                        );
                      },
                    ),
                  ),
                );
              }
          )
       ));
  }

}




/*
bySearchedWordsController.searchedArabicWordsList.isNotEmpty?ListView.builder(
        itemCount: bySearchedWordsController.totalSearchedDataList.length,
        itemBuilder: (context, index) {
          return ListTile(
            onTap: () {
              Get.to(() => SearchedListPage(), arguments: [query, index]);
            },
            title: Text(bySearchedWordsController.totalSearchedDataList[index]
                .toString()),
          );
        }):Container();
*/
/*
  ScrollbarTheme(
              data: ScrollbarThemeData(
                thumbColor: WidgetStateProperty.all(Colors.black38), // Change scrollbar color
                trackColor: WidgetStateProperty.all(Colors.grey[300]), // Track color
                thickness: WidgetStateProperty.all(8.0), // Scrollbar width
              ),
              child: Scrollbar(

                controller: bySearchedWordsController.scrollController,
                thickness:25.0 ,
                thumbVisibility: true,
                interactive: true,
                //radius: Radius.circular(10),
                child: ListView.separated(
                shrinkWrap: true,
                controller:bySearchedWordsController.scrollController,
                itemCount: bySearchedWordsController.consolidatedDataList.length,
                 // itemScrollController: itemScrollController,
                  //itemPositionsListener: itemPositionsListener,
                  // itemScrollController: bySearchedWordsController.itemScrollController,
                // itemPositionsListener: bySearchedWordsController.itemPositionsListener,
                           /* initialScrollIndex: bySearchedWordsController.searchState ==
                    'search_delegate' ?
                bySearchedWordsController.index.value : 0,*/
                itemBuilder: (context, index) {

                 /* if (index == bySearchedWordsController.consolidatedDataList.length-60) {
                    if (bySearchedWordsController.isLoading.value) {
                      return CircularProgressIndicator(); // Show loading indicator
                    } else {
                      bySearchedWordsController.fetchWordsDataByWord(Get.arguments[0],Get.arguments[1]); // Trigger next batch fetch
                      return SizedBox.shrink(); // Empty widget while loading
                    }
                  }*/


                  return LayoutBuilder(builder: (context,constraint){
                    return Padding(
                      padding: index == 0
                          ? EdgeInsets.only(top: 10.0)
                          : EdgeInsets.only(top: 0.0),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              decoration: BoxDecoration(
                                //color: Colors.white.withOpacity(0.3)
                                  gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [Colors.white60, Colors.white24]),
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                      width: 2, color: Colors.white30)),
                              child: ListTile(
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    TopPartSurahBox(
                                      surahId: bySearchedWordsController.consolidatedDataList[index].surahId!,
                                      verseId:  bySearchedWordsController.consolidatedDataList[index].verseId!,
                                      arabicName: bySearchedWordsController.consolidatedDataList[index].surahNameArabic!,
                                      englishName: bySearchedWordsController.consolidatedDataList[index].surahNameEnglish!,
                                      bengaliName: bySearchedWordsController.consolidatedDataList[index].surahNameBangla!,
                                      arabicTrans:  bySearchedWordsController.consolidatedDataList[index].arabicTranslation!,
                                      englishTrans:  bySearchedWordsController.consolidatedDataList[index].englishTranslation!,
                                      bengaliTrans:  bySearchedWordsController.consolidatedDataList[index].banglaTranslation!,
                                    ),
                                    WordByWordBoxPart(
                                        surahNameEnglish: bySearchedWordsController.consolidatedDataList[index].surahNameEnglish!,
                                        surahId: bySearchedWordsController.consolidatedDataList[index].surahId!,
                                        verseId:bySearchedWordsController.consolidatedDataList[index].verseId!,
                                        arabicWordList: bySearchedWordsController.consolidatedDataList[index].words!.arabic!,
                                        bengaliWordList: bySearchedWordsController.consolidatedDataList[index].words!.bangla!,
                                        englishWordList: bySearchedWordsController.consolidatedDataList[index].words!.english!,
                                        qWords: bySearchedWordsController.consolidatedDataList[index].qWords!,
                                        wordIds: bySearchedWordsController.consolidatedDataList[index].words!.wordIds!,
                                        arabic1: bySearchedWordsController.consolidatedDataList[index].arabicWordsData!.arabic1!,
                                        arabic2: bySearchedWordsController.consolidatedDataList[index].arabicWordsData!.arabic2!,
                                        arabic3: bySearchedWordsController.consolidatedDataList[index].arabicWordsData!.arabic3!,
                                        arabic4: bySearchedWordsController.consolidatedDataList[index].arabicWordsData!.arabic4!,
                                        arabic5: bySearchedWordsController.consolidatedDataList[index].arabicWordsData!.arabic5!,
                                        arabic: bySearchedWordsController.consolidatedDataList[index].words!.arabic!,
                                        root: bySearchedWordsController.consolidatedDataList[index].root!,
                                        lemma:bySearchedWordsController.consolidatedDataList[index].lemma!,
                                        typeEn1: bySearchedWordsController.consolidatedDataList[index].typeInfo!.typeEn1!,
                                        typeBn1: bySearchedWordsController.consolidatedDataList[index].typeInfo!.typeBn1!,
                                        typeEn2: bySearchedWordsController.consolidatedDataList[index].typeInfo!.typeEn2!,
                                        typeBn2: bySearchedWordsController.consolidatedDataList[index].typeInfo!.typeBn2!,
                                        typeEn3: bySearchedWordsController.consolidatedDataList[index].typeInfo!.typeEn3!,
                                        typeBn3: bySearchedWordsController.consolidatedDataList[index].typeInfo!.typeBn3!,
                                        typeEn4: bySearchedWordsController.consolidatedDataList[index].typeInfo!.typeEn4!,
                                        typeBn4: bySearchedWordsController.consolidatedDataList[index].typeInfo!.typeBn4!,
                                        typeEn5: bySearchedWordsController.consolidatedDataList[index].typeInfo!.typeEn5!,
                                        typeBn5: bySearchedWordsController.consolidatedDataList[index].typeInfo!.typeBn5!,
                                        bangla:bySearchedWordsController.consolidatedDataList[index].words!.bangla!,
                                        english: bySearchedWordsController.consolidatedDataList[index].words!.english!,
                                        arabicWords: bySearchedWordsController.consolidatedDataList[index].words!.arabic!,
                                        chosenWord: bySearchedWordsController.chosenWord.value
                                    ),
                                    TranslationsPartBox(
                                        englishTranslation: bySearchedWordsController.consolidatedDataList[index].englishTranslation!,
                                        banglaTranslation: bySearchedWordsController.consolidatedDataList[index].banglaTranslation!,
                                        indoTranslation: bySearchedWordsController.consolidatedDataList[index].indoTranslation!,
                                        ref1: bySearchedWordsController.consolidatedDataList[index].references!.ref1!,
                                        ref2: bySearchedWordsController.consolidatedDataList[index].references!.ref2!,
                                        ref3: bySearchedWordsController.consolidatedDataList[index].references!.ref3!,
                                        ref4: bySearchedWordsController.consolidatedDataList[index].references!.ref4!,
                                        ref5: bySearchedWordsController.consolidatedDataList[index].references!.ref5!
                                    ),

                                    const SizedBox(
                                      height: 10,
                                    )
                                  ],
                                ),
                                //selected:index == verseIndex ,
                              ),
                            ),
                          )),
                    );
                  });
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(
                    height: 10,
                  );
                },
                          ),
              ),
            )
 */