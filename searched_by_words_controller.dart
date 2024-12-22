import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:get/state_manager.dart';
import 'package:quran_app_with_flutter/business%20logics/searched_data_model_class.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sqflite/sqflite.dart';

import '../../Database/searched_data_by_words_resource.dart';
import '../../Database/sqlite_helper.dart';
import '../../Database/words_of_surah_data_resource.dart';



class BySearchedWordsController extends GetxController{
  RxBool isSearchClicked = false.obs;
  RxBool isfilled = false.obs;
  RxString searchState='search_1st'.obs;
  RxInt surahId=0.obs;
  RxInt verseId=0.obs;
  RxString chosenWord=''.obs;
  RxString chosenSearch=''.obs;
  RxList serachedResult = [].obs;
  RxList searchedArabicWordsList=[].obs;
  RxList searchedBengaliWordsList =[].obs;
  RxList searchedEnglishWordsList =[].obs;
  RxList wordsIdList =[].obs;
  RxList verseIdList =[].obs;
  RxList surahArabicNameList =[].obs;
  RxList surahEnglishNameList =[].obs;
  RxList surahBanglaNameList =[].obs;
  RxList surahNameEnglishMeaningList =[].obs;
  RxList surahIdList = [].obs;
  RxList totalSearchedDataList = [].obs;
  RxList arabic1 = [].obs;
  RxList arabic2 = [].obs;
  RxList arabic3 = [].obs;
  RxList arabic4 = [].obs;
  RxList arabic5 = [].obs;
  RxList root = [].obs;
  RxList lemma = [].obs;
  RxList searchedSurahId=[].obs;
  RxList searchedVerseId=[].obs;
  RxList arabicTranslation=[].obs;
  RxList englishTranslation=[].obs;
  RxList bengaliTranslation=[].obs;
  RxList indoTranslation=[].obs;
  RxList reference1=[].obs;
  RxList reference2=[].obs;
  RxList reference3=[].obs;
  RxList reference4=[].obs;
  RxList reference5=[].obs;
  RxList typeEn1=[].obs;
  RxList typeBn1=[].obs;
  RxList typeEn2=[].obs;
  RxList typeBn2=[].obs;
  RxList typeEn3=[].obs;
  RxList typeBn3=[].obs;
  RxList typeEn4=[].obs;
  RxList typeBn4=[].obs;
  RxList typeEn5=[].obs;
  RxList typeBn5=[].obs;
  RxList qWords=[].obs;
  RxInt index= 0.obs;
  var consolidatedDataList = <SearchedDataModel>[].obs;
 // var consolidatedDataList = List<SearchedDataModel?>.filled(2000, SearchedDataModel(), growable: false).obs;

  final textEditingController = TextEditingController();
  final text = ''.obs;
 // var currentPage = 0.obs;
 // final int itemsPerPage = 5;
  var isLoading = false.obs;
  RxBool firstLoad = true.obs;
 // bool isLastPage = false;
  var hasMoreData = true.obs;
 // int initialLimit = 3;
 // int subsequentLimit = 10;
  int offset = 0;
  int limit = 100;

  final RxInt totalCount=0.obs;
 // final ItemScrollController itemScrollController = ItemScrollController();
 // final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  ScrollController scrollController = ScrollController();



  setSelectedSearch(String search){
     chosenSearch.value= search;
  }
  setSelectedWord(String txt){
    chosenWord.value=txt;
  }
  setPage(String page){
    searchState.value=page;
  }
  setIndex(int id){
    index.value=id;
  }
  setVerseId(int indx){
    verseId.value=indx;
  }
  setSurahId(int value){
    surahId.value= value;
  }
  setIsSearchClicked(){
    isSearchClicked.value =  !isSearchClicked.value;
  }
  setCount(int value){
    totalCount.value=value;
  }
 /* @override
  void onInit() {
    super.onInit();
    // Add listener for scroll position
    itemPositionsListener.itemPositions.addListener(() {
      // Get the list of visible items
      final visibleIndexes = itemPositionsListener.itemPositions.value
          .map((item) => item.index)
          .toList();

      // If the last item is visible, and there is more data to load, trigger loadMore
      if (hasMoreData.value &&
          !isLoading.value &&
          visibleIndexes.contains(surahArabicNameList.length - 1)) {
        loadMore(chosenWord.value,chosenSearch.value); // Pass search parameters
      }
    });
  }*/
  fetchTotalCount(String word,String searchValue) async {

    ReceivePort receivePort = ReceivePort();
    RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;
    Database database = await DBHelper().database;


    await Isolate.spawn(
        SearchedDataByWords.getCount,
        [
          receivePort.sendPort,
          word,database,
          rootIsolateToken,
          searchValue,

        ]);


    receivePort.listen((data) {
      if (data is int) {
        print('count $data');
        print('Data received:');
        setCount(data);
        print('total count ${totalCount.value}');
      }
    });
  }
 Future<List<SearchedDataModel>> fetchWordsDataByWord(String word,String searchValue) async {
   // hasMoreData.value=true;
    print('in fetchWordsDataByWord ');
   // resetArrays();
    //if (isLoading.value) return;

    isLoading.value = true;

    ReceivePort receivePort = ReceivePort();
    RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;
    Database database = await DBHelper().database;



    print('before next loop');

    try{
      int limit = 50;//100;
      int offset = 0;
      await compute(
          SearchedDataByWords.getAllDesiredWords,
          [
            receivePort.sendPort,
            word,database,
            rootIsolateToken,
            searchValue,
            //itemsPerPage,
            //(currentPage.value - 1) * itemsPerPage
            limit,
            offset
          ]);

      receivePort.listen((data) async {
        if(data is List<SearchedDataModel>){


          consolidatedDataList.addAll(data);
          firstLoad.value= false;

          // offset += limit;

         //  limit=300;
          // Update the offset for further records
         /*



          offset += limit;*/
          await fetchWordsDataByWordMoreInfo(word, searchValue, totalCount.value-50,50);

        }

        //receivePort.close();
      });


    }finally {
      isLoading.value = false;
    }

    print('after next loop');

    print('consolidatedData ${consolidatedDataList}');
    return consolidatedDataList;

  }
 Future fetchWordsDataByWordMoreInfo(String word,String searchValue, int limit, int offset) async {

    //, Database database, RootIsolateToken rootIsolateToken
    if (isLoading.value) return;

    isLoading.value = true;

    ReceivePort receivePort = ReceivePort();
    RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;

    Database database = await DBHelper().database;

    await compute(
        SearchedDataByWords.getAllDesiredWordsMoreInfo,
        [
          receivePort.sendPort,
          word,
          database,
          rootIsolateToken,
          searchValue,
          limit,
          offset
        ]
    );
    receivePort.listen((data) {
      if (data is List<SearchedDataModel>) {
        print('object received');
        consolidatedDataList.addAll(data);

      }

    });
   /* if(consolidatedDataList.isNotEmpty){
        SchedulerBinding.instance.addPostFrameCallback((_){
          if(scrollController.hasClients){
            scrollController.animateTo(
                scrollController.position.minScrollExtent,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeOut
            );
          }
        });
      }*/
   //hasMoreData.value= false;
  }
  Future<void> fetchDifferentInfoOfASingleWord(int id) async {
    await Future.delayed(Duration(seconds: 1));
    ReceivePort receivePort = ReceivePort();
    RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;
    Database database = await DBHelper().database;
    await Isolate.spawn(WordsData.getDifferentInfoOfWords, [
      receivePort.sendPort,
      id,
      database,
      rootIsolateToken,
      //itemsPerPage,
      //(currentPage.value - 1) * itemsPerPage
      limit,
      offset
    ]);
    /*arabic1.value=[];
    arabic2.value=[];
    arabic3.value=[];
    arabic4.value=[];
    arabic5.value=[];*/
    receivePort.listen((data)  {

      if (data is List<List<dynamic>>) {
        print('Data received:');
        arabic1.value = data[0];
        arabic2.value = data[1];
        arabic3.value = data[2];
        arabic4.value = data[3];
        arabic5.value = data[4];

       // arabicWordsIds.value = data[5];
      }
    });
    print('arabic1 data $arabic1');
    print('arabic2 data $arabic2');
    print('arabic3 data $arabic3');
    print('arabic4 data $arabic4');
    print('arabic5 data $arabic5');

  }
  /*
   /*WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollController.jumpTo(
            scrollController.position.maxScrollExtent,  // Adjust the scroll position
          );
        });*/
  */

  Future<List<List<dynamic>>> fetchSuggestions(String quary) async {
    // List<dynamic> lst=[];
     ReceivePort receivePort = ReceivePort();
     RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;
     Database database = await DBHelper().database;
     await Isolate.spawn(SearchedDataByWords.fetchSearchSuggestion, [receivePort.sendPort, quary,database,rootIsolateToken]);

      final result = await receivePort.first as List<List<dynamic>>;


       receivePort.close();
       return result;
   }
   resetArrays(){
     /*searchedArabicWordsList.value=[];
     searchedBengaliWordsList.value=[];
     searchedEnglishWordsList.value=[];
     wordsIdList.value=[];
     verseIdList.value=[];
     arabic1.value=[];
     arabic2.value=[];
     arabic3.value=[];
     arabic4.value=[];
     arabic5.value=[];
     surahArabicNameList.value=[];
     surahEnglishNameList.value=[];
     surahBanglaNameList.value=[] ;
     surahNameEnglishMeaningList.value=[] ;
     surahIdList.value=[] ;
     totalSearchedDataList.value=[] ;
     arabicTranslation.value=[];
     englishTranslation.value=[] ;
     bengaliTranslation.value=[];
     indoTranslation.value=[] ;
     root.value=[];
     lemma.value=[] ;
     reference1.value=[];
     reference2.value=[] ;
     reference3..value=[];
     reference4.value=[] ;
     reference5.value=[] ;
     typeEn1.value=[] ;
     typeBn1.value=[] ;
     typeEn2.value=[] ;
     typeBn2.value=[];
     typeEn3.value=[] ;
     typeBn3.value=[] ;
     typeEn4.value=[] ;
     typeBn4..value=[];
     typeEn5.value=[];
     typeBn5.value=[];
     qWords.value=[];*/
     consolidatedDataList.value=[];
     isLoading.value = false;
    // totalCount.value=0;

   }
  /*void loadMore(String word, String searchValue) {
    if (hasMoreData.value) {
      fetchWordsDataByWord(word, searchValue);
    }
  }*/


}