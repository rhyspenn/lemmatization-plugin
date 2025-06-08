/**
 * English Lemmatization Plugin for Bob
 * 提供英文单词的词形变化查询功能
 * 支持任何语言输入，查询英文词汇的词形变化
 */

// 词形变化数据存储
var lemmatizationData = null;

// 支持的语言配置 - 支持任何语言到任何语言的词形变化查询
var items = [
    ['auto', 'auto'],   // 自动检测 -> 自动检测
    ['en', 'zh-Hans'],  // 英文 -> 中文简体
    ['en', 'zh-Hant'],  // 英文 -> 中文繁体  
    ['en', 'ja'],       // 英文 -> 日文
    ['en', 'ko'],       // 英文 -> 韩文
    ['en', 'fr'],       // 英文 -> 法文
    ['en', 'de'],       // 英文 -> 德文
    ['en', 'es'],       // 英文 -> 西班牙文
    ['en', 'ru'],       // 英文 -> 俄文
    ['en', 'auto'],     // 英文 -> 自动检测
    ['en', 'en'],       // 英文 -> 英文
    ['zh-Hans', 'en'],  // 中文简体 -> 英文
    ['zh-Hant', 'en'],  // 中文繁体 -> 英文
    ['ja', 'en'],       // 日文 -> 英文
    ['ko', 'en'],       // 韩文 -> 英文
    ['fr', 'en'],       // 法文 -> 英文
    ['de', 'en'],       // 德文 -> 英文
    ['es', 'en'],       // 西班牙文 -> 英文
    ['ru', 'en'],       // 俄文 -> 英文
    ['auto', 'en'],     // 自动检测 -> 英文
    ['zh-Hans', 'zh-Hans'], // 中文简体 -> 中文简体
    ['zh-Hant', 'zh-Hant'], // 中文繁体 -> 中文繁体
    ['ja', 'ja'],       // 日文 -> 日文
    ['ko', 'ko'],       // 韩文 -> 韩文
    ['fr', 'fr'],       // 法文 -> 法文
    ['de', 'de'],       // 德文 -> 德文
    ['es', 'es'],       // 西班牙文 -> 西班牙文
    ['ru', 'ru'],       // 俄文 -> 俄文
];

var langMap = new Map(items);
var langMapReverse = new Map(items.map(([standardLang, lang]) => [lang, standardLang]));

// 此方法是 Bob 插件必须的，不要动
function supportLanguages() {
    return items.map(([standardLang, lang]) => standardLang);
}

/**
 * 加载词形变化数据
 * @returns {Map} 词汇映射表
 */
function loadLemmatizationData() {
    if (lemmatizationData !== null) {
        return lemmatizationData;
    }

    try {
        // 检查词形变化文件是否存在
        var filePath = '/lemmatization-en.txt';
        if (!$file.exists(filePath)) {
            throw new Error('词形变化数据文件 lemmatization-en.txt 不存在');
        }

        // 读取词形变化文件
        var dataObject = $file.read(filePath);
        if (!dataObject) {
            throw new Error('无法读取 lemmatization-en.txt 文件');
        }

        // 将 $data 对象转换为 UTF-8 字符串
        var content = dataObject.toUTF8();
        if (!content) {
            throw new Error('文件内容不是有效的 UTF-8 格式');
        }

        lemmatizationData = new Map();
        var reverseData = new Map(); // 用于反向查找

        // 解析文件内容
        var lines = content.split('\n');
        var lineCount = 0;
        var validLineCount = 0;

        for (var i = 0; i < lines.length; i++) {
            lineCount++;
            var line = lines[i].trim();

            // 跳过空行和注释行
            if (!line || line.startsWith('//') || line.startsWith('#')) {
                continue;
            }

            // 解析制表符分隔的数据
            var parts = line.split('\t');
            if (parts.length >= 2) {
                var base = parts[0].trim().toLowerCase();
                var inflected = parts[1].trim().toLowerCase();

                // 验证数据有效性
                if (base && inflected && base !== inflected) {
                    validLineCount++;

                    // 建立映射关系
                    if (!lemmatizationData.has(base)) {
                        lemmatizationData.set(base, new Set());
                    }
                    lemmatizationData.get(base).add(inflected);

                    // 反向映射（从变形词找到原形）
                    if (!reverseData.has(inflected)) {
                        reverseData.set(inflected, new Set());
                    }
                    reverseData.get(inflected).add(base);
                }
            } else if (parts.length > 0) {
                $log.warn('第 ' + lineCount + ' 行数据格式错误: ' + line);
            }
        }

        // 合并正向和反向数据
        reverseData.forEach(function (baseWords, inflected) {
            baseWords.forEach(function (base) {
                if (!lemmatizationData.has(inflected)) {
                    lemmatizationData.set(inflected, new Set());
                }
                // 添加原形词和其他变形
                lemmatizationData.get(inflected).add(base);
                if (lemmatizationData.has(base)) {
                    lemmatizationData.get(base).forEach(function (form) {
                        lemmatizationData.get(inflected).add(form);
                    });
                }
            });
        });

        $log.info('词形变化数据加载完成: 处理了 ' + lineCount + ' 行，有效数据 ' + validLineCount + ' 条，生成映射 ' + lemmatizationData.size + ' 个');

        return lemmatizationData;
    } catch (error) {
        $log.error('加载词形变化数据失败: ' + error.message);
        $log.error('错误详情: ' + JSON.stringify({
            errorType: error.name || 'UnknownError',
            errorMessage: error.message,
            filePath: '/lemmatization-en.txt'
        }));
        lemmatizationData = new Map();
        return lemmatizationData;
    }
}

/**
 * 查找单词的所有词形变化（排除查询词本身）
 * @param {string} word 输入单词
 * @returns {Array} 除查询词外的其他词形变化列表
 */
function findWordForms(word) {
    var data = loadLemmatizationData();
    var lowerWord = word.toLowerCase();
    var originalWord = word; // 保存原始查询词
    var forms = new Set();

    // 直接查找
    if (data.has(lowerWord)) {
        data.get(lowerWord).forEach(function (form) {
            forms.add(form);
        });
    }

    // 转换为数组并过滤掉查询词本身
    var formsArray = Array.from(forms).filter(function (form) {
        // 排除查询词的各种形式（原始形式、小写形式）
        return form !== lowerWord && form !== originalWord;
    }).sort();

    return formsArray;
}


function translate(query, completion) {
    try {
        // 检查输入参数
        if (!query || !query.text) {
            completion({
                'error': {
                    'type': 'param',
                    'message': '缺少查询文本',
                    'addtion': '请输入要查询的英文单词'
                }
            });
            return;
        }

        // 获取语言信息（用于返回结果）
        var fromLang = query.detectFrom || 'auto';
        var toLang = query.detectTo || 'auto';

        var inputText = query.text.trim();

        // 处理多个单词的情况
        var words = inputText.split(/\s+/);
        var results = [];

        for (var i = 0; i < words.length; i++) {
            var word = words[i].replace(/[^\w]/g, ''); // 移除标点符号
            if (word) {
                var forms = findWordForms(word);
                if (forms.length > 0) { // 如果找到了其他词形变化
                    results.push({
                        word: word,
                        forms: forms
                    });
                }
            }
        }

        // 构建返回结果
        var result = {};

        if (results.length > 0) {
            // 生成主要翻译结果
            var mainResult = '';
            var detailResults = [];

            for (var j = 0; j < results.length; j++) {
                var wordResult = results[j];
                // 只显示词形变化，不显示原词
                mainResult += wordResult.forms.join(', ') + '\n';

                // 添加详细的词形变化信息
                detailResults.push({
                    type: 'text',
                    title: wordResult.word + ' 的词形变化',
                    subtitle: wordResult.forms.length + ' 种形式',
                    text: wordResult.forms.join('\n')
                });
            }

            result = {
                'from': fromLang,
                'to': toLang,
                'toParagraphs': [mainResult.trim()],
                'toDict': {
                    'word': inputText,
                    'phonetics': [],
                    'parts': detailResults
                }
            };
        } else {
            // 没有找到词形变化
            result = {
                'from': fromLang,
                'to': toLang,
                'toParagraphs': ['未找到 "' + inputText + '" 的词形变化'],
                'toDict': {
                    'word': inputText,
                    'phonetics': [],
                    'parts': [{
                        'type': 'text',
                        'title': '查询结果',
                        'text': '该单词可能是基本形式，或不在词形变化数据库中'
                    }]
                }
            };
        }

        completion({ 'result': result });

    } catch (error) {
        $log.error('翻译过程中发生错误: ' + error.message);
        completion({
            'error': {
                'type': 'unknown',
                'message': '查询失败',
                'addtion': error.message
            }
        });
    }
}
