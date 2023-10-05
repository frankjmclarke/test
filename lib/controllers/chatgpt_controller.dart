import 'dart:math';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shopping_lister/controllers/storage_controller.dart';
import 'package:shopping_lister/controllers/string_list_controller.dart';
import '../helpers/checksum_helper.dart';
import 'csv_init.dart';
import 'keyword_controller.dart';

class ChatGPTController extends GetxController {
  static ChatGPTController get to => Get.find();
  final StorageController _storageController = Get.find<StorageController>();
  final apiKey = dotenv.env['CHAT_GPT_KEY'];
  RxString response = ''.obs;
  late OpenAI openAI;
  bool isInitted = false;
  final KeywordController _keywordController = Get.put(KeywordController());

/*
  Future<CompleteResponse?>? _translateFuture;

  void _translateEngToThai() async {
    final request = CompleteText(
        prompt: translateEngToThai(word: _txtWord.text.toString()),
        maxTokens: 200,
        model: TextDavinci3Model());

    _translateFuture = openAI.onCompletion(request: request);
  }*/

  void chatUnused(String myPrompt, double temperature) async {
    String prompt =
        "As your personal shopper, I assist in finding items related to the topic of " +
            myPrompt +
            ". I will generate additional keywords one at a time, providing you with suggestions that are closely related or commonly paired with the topic, as well as alternatives and substitutions. Additionally, I will offer keywords for items that have a more loose association with your topic, allowing for a wider range of options. Let's begin with the first set of additional keywords.";
    chat(prompt, temperature, true);
  }

// and suggest alternatives and substitutions
  Future<List<String>> chat1(String myPrompt, double temperature) async {
    String prompt = "As my personal shopper, consider " +
        myPrompt +
        " items. Generate 10 related keywords. Show only unnumbered keywords, no headers";
    return chat(prompt, temperature, true);
  }

  Future<List<String>> chat(
      String myPrompt, double temperature, bool extraKeywords) async {
    if (!isInitted) {
      initAI();
      isInitted = true;
    }
    if (temperature >= 1)
      temperature = 0.9;
    else if (temperature < 0.1) temperature = 0.1;
    final request = ChatCompleteText(
      messages: [
        Messages(role: Role.user, content: myPrompt, name: 'Frankie'),
      ],
      temperature: temperature,
      maxToken: 300,
      model: GptTurbo0301ChatModel(),
    );
    ChatCTResponse? resp = await openAI.onChatCompletion(request: request);
    response.value = resp?.choices[0].message?.content ?? "Empty Response";
    print("$response");

    List<String> keywords = extractKeywords(response.value);
    if (extraKeywords) {
      Set<String> extraKeywords = _storageController.readWordsFromNameFields();
      Set<String> uniqueKeywords = {...keywords, ...extraKeywords};
      keywords = uniqueKeywords.toList();
    }
    _keywordController.saveUrlList(keywords, 1);
    List<String> keywords2 = concatenateKeywords(keywords);
    return keywords2;
  }

  String replaceSpacesWithPlus(String text) {
    return text.replaceAll(RegExp(r'\s+'), '+');
  }

  List<String> extractKeywords(String input) {
    List<String> lines = input.split('\n');
    List<String> keywords = [];

    for (String line in lines) {
      if (line.trim().startsWith('- ')) {
        String keyword = line.substring(2).trim();
        keywords.add(keyword);
      }
    }

    return keywords;
  }

  List<String> concatenateKeywords(List<String> keywords) {
    List<String> concatenatedList = [];
    Random random = Random();
    if (keywords.length >= 2) {
      for (int i = 0; i < 5; i++) {
        int index1 = random.nextInt(keywords.length);
        int index2;

        do {
          index2 = random.nextInt(keywords.length);
        } while (index1 == index2);

        String concatenatedString = '${keywords[index1]}, ${keywords[index2]}';
        concatenatedList.add(concatenatedString);
      }
    }

    return concatenatedList;
  }

  void gpt4() async {
    final request = ChatCompleteText(messages: [
      Messages(role: Role.assistant, content: 'Hello!'),
    ], maxToken: 200, model: Gpt4ChatModel());

    await openAI.onChatCompletion(request: request);
  }

  void initAI() {
    openAI = OpenAI.instance.build(
        token: apiKey,
        baseOption: HttpSetup(
            receiveTimeout: const Duration(seconds: 20),
            connectTimeout: const Duration(seconds: 20)),
        enableLog: true);
  }

//////////////////////////////////////////////////////////////////////////////////////////////////
  final language = "".obs;
  final store = GetStorage(); // store language

  String get currentLanguage => language.value;

  @override
  void onReady() async {
    super.onInit();
  }

// updates the language stored
  Future<void> updateLanguage(String value) async {
    language.value = value;
    await store.write('language', value);

    update();
  }

  ////////////////////////////////////////////////////////////
  Future<void> doAi() async {
    final StringListController _keywordsController =
        Get.find<StringListController>();

    var nameList = _storageController.readNameCSV();
    List<String> keywords = await chat1(nameList, 0.9);
    _keywordsController.mergeIn(keywords);
    _keywordsController.saveStringList();
  }

  Future<void> callAi() async {
    final StringListController _checksumController =
        Get.find<StringListController>();

    int checksum2 =
        ChecksumHelper.calculateChecksum(_storageController.getAllUids());

    _checksumController.initCSV(CsvFiles.checksumInit());
    _checksumController.loadStringList('shopchecksum');
    int rowIndex = 0;

    String de_coded_int1 = _checksumController.csvGetter(rowIndex, 'checksum1');
    //String de_coded_int2 = _checksumController.csvGetter(rowIndex, 'checksum2');
    if (de_coded_int1.isNotEmpty) {
      int checksum1 = int.parse(de_coded_int1);
      _checksumController.emptyList();
      _checksumController.csvAdd(CsvFiles.checksumString(checksum1, checksum2));

      if (checksum1 == checksum2) {
        _checksumController.emptyList();
        _checksumController
            .csvAdd(CsvFiles.checksumString(checksum1, checksum2));
        await doAi();
      }
    }
  }
}
