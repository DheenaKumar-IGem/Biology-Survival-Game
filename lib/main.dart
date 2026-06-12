import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'blood_defense.dart';
import 'game_logic.dart';
import 'lesson_database_loader.dart';
import 'survivor_logic.dart';

part 'game_impl.dart';

void main() {
  runApp(const SquareShooterApp());
}

class SquareShooterApp extends StatelessWidget {
  const SquareShooterApp({super.key, this.gameFactory});

  final SquareShooterGame Function()? gameFactory;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2EC4B6),
      brightness: Brightness.dark,
      primary: const Color(0xFF8BE9E0),
      secondary: const Color(0xFFFFD166),
      surface: const Color(0xFF102621),
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Charlotte - HS',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFF071713),
        cardTheme: CardThemeData(
          color: const Color(0xFF102A24).withValues(alpha: 0.94),
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Color(0xFF1E5D52), width: 1.2),
          ),
        ),
        textTheme: ThemeData.dark().textTheme.copyWith(
              displayLarge: const TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.4,
              ),
              headlineMedium: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
              ),
              titleLarge: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
              bodyLarge: const TextStyle(
                fontSize: 16,
                height: 1.45,
              ),
            ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF2EC4B6),
            foregroundColor: const Color(0xFF04110D),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFD8F3DC),
            side: const BorderSide(color: Color(0xFF2EC4B6)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        chipTheme: const ChipThemeData(
          backgroundColor: Color(0xFF14332B),
          disabledColor: Color(0xFF0B1F1A),
          selectedColor: Color(0xFF176C62),
          secondarySelectedColor: Color(0xFF2EC4B6),
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          labelStyle: TextStyle(color: Color(0xFFD8F3DC)),
          secondaryLabelStyle: TextStyle(color: Color(0xFF04110D)),
          brightness: Brightness.dark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            side: BorderSide(color: Color(0xFF176C62)),
          ),
          side: BorderSide(color: Color(0xFF176C62)),
        ),
      ),
      home: Scaffold(
        body: GameWidget<SquareShooterGame>.controlled(
          gameFactory: gameFactory ?? SquareShooterGame.new,
          overlayBuilderMap: {
            HudOverlay.id: (BuildContext _, SquareShooterGame game) =>
                HudOverlay(game: game),
            TitleOverlay.id: (BuildContext _, SquareShooterGame game) =>
                TitleOverlay(game: game),
            TutorialOverlay.id: (BuildContext _, SquareShooterGame game) =>
                TutorialOverlay(game: game),
            InteractiveTutorialOverlay.id:
                (BuildContext _, SquareShooterGame game) =>
                    InteractiveTutorialOverlay(game: game),
            LevelOverlay.id: (BuildContext _, SquareShooterGame game) =>
                LevelOverlay(game: game),
            PauseOverlay.id: (BuildContext _, SquareShooterGame game) =>
                PauseOverlay(game: game),
            StarterDraftOverlay.id: (BuildContext _, SquareShooterGame game) =>
                StarterDraftOverlay(game: game),
            CombatLevelOverlay.id: (BuildContext _, SquareShooterGame game) =>
                CombatLevelOverlay(game: game),
            DesignInterviewOverlay.id:
                (BuildContext _, SquareShooterGame game) =>
                    DesignInterviewOverlay(game: game),
            ContextTipOverlay.id: (BuildContext _, SquareShooterGame game) =>
                ContextTipOverlay(game: game),
            VictoryOverlay.id: (BuildContext _, SquareShooterGame game) =>
                VictoryOverlay(game: game),
            GameOverOverlay.id: (BuildContext _, SquareShooterGame game) =>
                GameOverOverlay(game: game),
          },
          initialActiveOverlays: const [HudOverlay.id, TitleOverlay.id],
        ),
      ),
    );
  }
}

class GlossaryEntry {
  const GlossaryEntry({
    required this.term,
    required this.definition,
    this.aliases = const [],
  });

  final String term;
  final String definition;
  final List<String> aliases;
}

const List<GlossaryEntry> glossaryEntries = [
  GlossaryEntry(
      term: 'Pancreas',
      definition:
          'An organ near the stomach that helps with digestion and blood sugar.'),
  GlossaryEntry(
      term: 'Organ',
      definition: 'A body part made of tissues that does a special job.'),
  GlossaryEntry(
      term: 'Tissue', definition: 'A group of similar cells working together.'),
  GlossaryEntry(term: 'Cell', definition: 'The basic unit of life.'),
  GlossaryEntry(term: 'Duct', definition: 'A small tube that carries fluid.'),
  GlossaryEntry(
      term: 'Gland',
      definition: 'An organ or tissue that makes and releases substances.'),
  GlossaryEntry(
      term: 'Digestive system',
      definition: 'The body system that breaks down food.'),
  GlossaryEntry(
      term: 'Endocrine system',
      definition: 'The body system that makes hormones.'),
  GlossaryEntry(
      term: 'Hormone',
      definition: 'A chemical message that travels in the blood.'),
  GlossaryEntry(
      term: 'Enzyme',
      definition:
          'A protein that speeds up a chemical reaction, such as digestion.'),
  GlossaryEntry(
      term: 'Cell membrane',
      definition: 'The thin outer layer that surrounds a cell.'),
  GlossaryEntry(
      term: 'Cytoplasm', definition: 'The jelly-like material inside a cell.'),
  GlossaryEntry(
      term: 'Nucleus',
      definition: 'The control center of a cell that holds DNA.'),
  GlossaryEntry(
      term: 'DNA',
      definition: 'The molecule that stores genetic instructions.'),
  GlossaryEntry(
      term: 'Gene',
      definition: 'A section of DNA that helps give instructions to the cell.'),
  GlossaryEntry(
      term: 'Chromosome', definition: 'A packaged bundle of DNA in a cell.'),
  GlossaryEntry(
      term: 'Protein',
      definition: 'A molecule that does many jobs in cells and tissues.'),
  GlossaryEntry(
      term: 'Receptor', definition: 'A cell part that receives a signal.'),
  GlossaryEntry(
      term: 'Signal', definition: 'A message telling a cell what to do.'),
  GlossaryEntry(
      term: 'Cell division',
      definition: 'The process of one cell becoming two cells.'),
  GlossaryEntry(
      term: 'Mitosis',
      definition: 'A type of cell division that makes two similar cells.'),
  GlossaryEntry(
      term: 'Cancer',
      definition: 'A disease in which cells grow out of control.'),
  GlossaryEntry(
      term: 'Tumor', definition: 'An abnormal lump or mass of cells.'),
  GlossaryEntry(
      term: 'Benign', definition: 'Not cancer and not likely to spread.'),
  GlossaryEntry(
      term: 'Malignant', definition: 'Cancerous and able to invade or spread.'),
  GlossaryEntry(term: 'Growth', definition: 'An increase in size or number.'),
  GlossaryEntry(
      term: 'Spread', definition: 'To move from one place to another.'),
  GlossaryEntry(
      term: 'Metastasis',
      definition: 'Cancer spread to another part of the body.'),
  GlossaryEntry(
      term: 'Invasion', definition: 'Cancer growing into nearby tissue.'),
  GlossaryEntry(term: 'Mass', definition: 'A lump of tissue.'),
  GlossaryEntry(
      term: 'Lesion', definition: 'An area of damaged or abnormal tissue.'),
  GlossaryEntry(term: 'Mutation', definition: 'A change in DNA.'),
  GlossaryEntry(
      term: 'Inheritance',
      definition: 'Receiving genes and traits from parents.'),
  GlossaryEntry(
      term: 'Genetic change', definition: 'A change in DNA or genes.'),
  GlossaryEntry(term: 'DNA damage', definition: 'Harm to the DNA in a cell.'),
  GlossaryEntry(term: 'Repair', definition: 'The process of fixing damage.'),
  GlossaryEntry(
      term: 'Disease',
      definition: 'A health problem that affects how the body works.'),
  GlossaryEntry(
      term: 'Disorder',
      definition: 'A condition in which the body is not working normally.'),
  GlossaryEntry(
      term: 'Infection',
      definition: 'A disease caused by germs such as bacteria or viruses.'),
  GlossaryEntry(
      term: 'Inflammation',
      definition:
          'The body reaction to injury or infection, often causing redness, heat, or swelling.'),
  GlossaryEntry(
      term: 'Pain',
      definition: 'An unpleasant feeling that can signal injury or illness.'),
  GlossaryEntry(
      term: 'Swelling',
      definition: 'An area becoming larger because of fluid or inflammation.'),
  GlossaryEntry(term: 'Jaundice', definition: 'Yellowing of the skin or eyes.'),
  GlossaryEntry(term: 'Weight loss', definition: 'Losing body weight.'),
  GlossaryEntry(
      term: 'Test', definition: 'A way to check for a disease or problem.'),
  GlossaryEntry(
      term: 'Scan',
      definition: 'A machine-made picture of the inside of the body.'),
  GlossaryEntry(
      term: 'Imaging',
      definition: 'Making pictures of the inside of the body.'),
  GlossaryEntry(
      term: 'Blood test', definition: 'A test that uses a blood sample.'),
  GlossaryEntry(
      term: 'Biopsy',
      definition: 'A small sample of tissue or cells taken for testing.'),
  GlossaryEntry(
      term: 'Sample', definition: 'A small amount taken for testing.'),
  GlossaryEntry(
      term: 'Salivary testing',
      definition: 'Testing saliva, or spit, for useful health information.'),
  GlossaryEntry(
      term: 'Diagnosis',
      definition: 'Finding out what disease or condition a person has.'),
  GlossaryEntry(
      term: 'Treatment',
      definition: 'Care used to help a disease or condition.'),
  GlossaryEntry(
      term: 'Surgery', definition: 'Treatment done with an operation.'),
  GlossaryEntry(
      term: 'Medicine', definition: 'A drug used to treat or prevent disease.'),
  GlossaryEntry(
      term: 'Chemotherapy',
      definition:
          'Drug treatment used to kill cancer cells or slow their growth.'),
  GlossaryEntry(
      term: 'Radiation',
      definition: 'High-energy rays used in some cancer treatments.'),
  GlossaryEntry(
      term: 'Therapy', definition: 'Treatment meant to help a condition.'),
  GlossaryEntry(
      term: 'Recovery',
      definition: 'Getting better after illness or treatment.'),
  GlossaryEntry(
      term: 'Smoking', definition: 'Using tobacco such as cigarettes.'),
  GlossaryEntry(
      term: 'Diet', definition: 'The kinds of food a person usually eats.'),
  GlossaryEntry(term: 'Age', definition: 'How old a person is.'),
  GlossaryEntry(
      term: 'Family history',
      definition: 'Health problems that run in a family.'),
  GlossaryEntry(
      term: 'Health',
      definition: 'The overall condition of the body and mind.'),
];

final Map<String, GlossaryEntry> glossaryByAlias = _buildGlossaryByAlias();

Map<String, GlossaryEntry> _buildGlossaryByAlias() {
  final map = <String, GlossaryEntry>{};
  for (final entry in glossaryEntries) {
    for (final alias in <String>{entry.term, ...entry.aliases}) {
      map[alias.toLowerCase()] = entry;
    }
  }
  return map;
}

GlossaryEntry? glossaryForTerm(String term) {
  return glossaryByAlias[term.toLowerCase()];
}

List<InlineSpan> buildGlossarySpans(BuildContext context, String text) {
  final lowerText = text.toLowerCase();
  final activeAliases = <String>[];
  for (final entry in glossaryEntries) {
    for (final alias in <String>{entry.term, ...entry.aliases}) {
      final lowerAlias = alias.toLowerCase();
      if (lowerText.contains(lowerAlias)) {
        activeAliases.add(lowerAlias);
      }
    }
  }

  if (activeAliases.isEmpty) {
    return [TextSpan(text: text)];
  }

  activeAliases.sort((a, b) => b.length.compareTo(a.length));
  final pattern = activeAliases.map(RegExp.escape).join('|');
  final regex = RegExp(
    r'(?<![A-Za-z0-9])(' + pattern + r')(?![A-Za-z0-9])',
    caseSensitive: false,
  );

  final spans = <InlineSpan>[];
  var lastEnd = 0;
  for (final match in regex.allMatches(text)) {
    if (match.start > lastEnd) {
      spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
    }
    final matchedText = text.substring(match.start, match.end);
    final entry = glossaryForTerm(matchedText);
    if (entry == null) {
      spans.add(TextSpan(text: matchedText));
    } else {
      spans.add(
        TextSpan(
          text: matchedText,
          style: const TextStyle(
            color: Color(0xFF7DD3FC),
            decoration: TextDecoration.underline,
            fontWeight: FontWeight.w600,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () => showGlossaryDefinition(context, entry),
        ),
      );
    }
    lastEnd = match.end;
  }

  if (lastEnd < text.length) {
    spans.add(TextSpan(text: text.substring(lastEnd)));
  }

  return spans;
}

void showGlossaryDefinition(BuildContext context, GlossaryEntry entry) {
  showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(entry.term),
        content: Text(entry.definition),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}

const List<LessonContent> bundledLessonSequence = <LessonContent>[
  LessonContent(
    unitNumber: 1,
    unitTitle: 'Basic Anatomy',
    title: 'Unit 1: The pancreas and body systems',
    sourceTitle: '''NCI Dictionary of Cancer Terms � pancreas
MedlinePlus � Digestive System''',
    sourceUrl:
        '''https://www.cancer.gov/publications/dictionaries/cancer-terms/def/pancreas
https://medlineplus.gov/digestivesystem.html''',
    sourceCredit: 'Adapted from NCI and MedlinePlus in simpler language.',
    prompt:
        'This course now starts with very basic body words. Read the passage, then answer three questions.',
    readingText:
        'The pancreas is an organ. An organ is a body part made of tissues, and a tissue is made of many cells. The pancreas is a gland because it makes useful substances for the body. It helps the digestive system by sending enzymes through a duct to help break down food. It also helps the endocrine system by making hormones, which are chemical messages that travel in the blood. So the pancreas has two big jobs: helping digest food and helping control blood sugar.',
    keyTerms: [
      'Pancreas',
      'Organ',
      'Tissue',
      'Cell',
      'Duct',
      'Gland',
      'Digestive system',
      'Endocrine system',
      'Hormone',
      'Enzyme',
    ],
    questions: [
      LessonQuestion(
        prompt: 'What is the pancreas?',
        choices: [
          'An organ that helps with digestion and blood sugar',
          'A type of bone',
          'A blood cell',
          'A kind of bacteria',
        ],
        correctIndex: 0,
      ),
      LessonQuestion(
        prompt: 'What does a duct do?',
        choices: [
          'It carries fluid through a small tube',
          'It pumps blood like the heart',
          'It stores thoughts in the brain',
          'It makes bones hard',
        ],
        correctIndex: 0,
      ),
      LessonQuestion(
        prompt: 'Why is the pancreas called both digestive and endocrine?',
        choices: [
          'Because it helps digest food and also makes hormones',
          'Because it only makes skin cells',
          'Because it only stores water',
          'Because it does no job in the body',
        ],
        correctIndex: 0,
      ),
    ],
  ),
  LessonContent(
    unitNumber: 2,
    unitTitle: 'Basic Cell Biology',
    title: 'Unit 2: Inside a cell',
    sourceTitle: '''MedlinePlus Genetics � What is a cell?
MedlinePlus Genetics � What is DNA?
MedlinePlus Genetics � What is a chromosome?''',
    sourceUrl: '''https://medlineplus.gov/genetics/understanding/basics/cell/
https://medlineplus.gov/genetics/understanding/basics/dna/
https://medlineplus.gov/genetics/understanding/basics/chromosome/''',
    sourceCredit: 'Adapted from MedlinePlus Genetics in simpler language.',
    prompt:
        'Now move inside the cell and learn the words that appear in basic biology.',
    readingText:
        'A cell has parts with different jobs. The cell membrane is the outside layer that helps protect the cell. Inside is the cytoplasm, a jelly-like material where many cell jobs happen. The nucleus is the part that holds DNA. DNA contains genes, and genes are instructions for making proteins. Proteins help cells work. Cells also use receptors to receive a signal from outside the cell. When a cell gets the right signal, it may grow or divide. Cell division is how one cell becomes two cells, and mitosis is one common kind of cell division.',
    keyTerms: [
      'Cell membrane',
      'Cytoplasm',
      'Nucleus',
      'DNA',
      'Gene',
      'Chromosome',
      'Protein',
      'Receptor',
      'Signal',
      'Cell division',
      'Mitosis',
    ],
    questions: [
      LessonQuestion(
        prompt: 'Where is DNA found in this lesson?',
        choices: [
          'In the nucleus',
          'Only outside the body',
          'In the duct',
          'In food only',
        ],
        correctIndex: 0,
      ),
      LessonQuestion(
        prompt: 'What does a receptor do?',
        choices: [
          'It receives a signal',
          'It becomes a whole organ',
          'It turns into bone',
          'It stores bile',
        ],
        correctIndex: 0,
      ),
      LessonQuestion(
        prompt: 'What is mitosis?',
        choices: [
          'A type of cell division',
          'A kind of infection',
          'A surgery',
          'A hormone',
        ],
        correctIndex: 0,
      ),
    ],
  ),
  LessonContent(
    unitNumber: 3,
    unitTitle: 'Basic Cancer Terms',
    title: 'Unit 3: Cancer, tumors, and spread',
    sourceTitle: '''NCI Dictionary of Cancer Terms � cancer
NCI Dictionary of Cancer Terms � tumor
NCI Dictionary of Cancer Terms � metastasis''',
    sourceUrl:
        '''https://www.cancer.gov/publications/dictionaries/cancer-terms/def/cancer
https://www.cancer.gov/publications/dictionaries/cancer-terms/def/tumor
https://www.cancer.gov/publications/dictionaries/cancer-terms/def/metastasis''',
    sourceCredit: 'Adapted from NCI in simpler language.',
    prompt: 'These are the first cancer words a beginner should know.',
    readingText:
        'Cancer is a disease in which cells grow too much and do not follow normal rules. A tumor is a mass, or lump, made of abnormal cells. Some tumors are benign, which means they are not cancer and are not expected to spread. Other tumors are malignant, which means they are cancer and can invade nearby tissue. If cancer cells spread far away and grow in a new place, that is called metastasis. Doctors may also use the word lesion for an area of abnormal tissue seen on a scan or in the body.',
    keyTerms: [
      'Cancer',
      'Tumor',
      'Benign',
      'Malignant',
      'Growth',
      'Spread',
      'Metastasis',
      'Invasion',
      'Mass',
      'Lesion',
    ],
    questions: [
      LessonQuestion(
        prompt: 'What is a tumor?',
        choices: [
          'An abnormal mass of cells',
          'A healthy hormone',
          'A type of white blood cell',
          'A duct full of enzymes',
        ],
        correctIndex: 0,
      ),
      LessonQuestion(
        prompt: 'What does malignant mean?',
        choices: [
          'Cancerous and able to invade or spread',
          'Always harmless',
          'Part of normal digestion',
          'A kind of imaging test',
        ],
        correctIndex: 0,
      ),
      LessonQuestion(
        prompt: 'What is metastasis?',
        choices: [
          'Cancer spreading to another part of the body',
          'A cell fixing DNA',
          'The body making insulin',
          'A type of exercise',
        ],
        correctIndex: 0,
      ),
    ],
  ),
  LessonContent(
    unitNumber: 4,
    unitTitle: 'Basic Genetics',
    title: 'Unit 4: DNA changes and inheritance',
    sourceTitle: '''MedlinePlus Genetics � What is DNA?
MedlinePlus Genetics � What is a gene?
NCI Dictionary of Cancer Terms � mutation''',
    sourceUrl: '''https://medlineplus.gov/genetics/understanding/basics/dna/
https://medlineplus.gov/genetics/understanding/basics/gene/
https://www.cancer.gov/publications/dictionaries/cancer-terms/def/46063''',
    sourceCredit:
        'Adapted from MedlinePlus Genetics and NCI in simpler language.',
    prompt:
        'This unit keeps genetics simple and focuses on the words beginners see first.',
    readingText:
        'Genes are written in DNA, and DNA can change. A mutation is a change in DNA. Some genetic changes are inherited, which means they are passed from parent to child. Other changes happen later during life. DNA can also be damaged by mistakes or by harmful exposures. Cells have repair systems that try to fix DNA damage. When repair does not work well, more genetic changes can build up over time.',
    keyTerms: [
      'Mutation',
      'Inheritance',
      'Genetic change',
      'DNA damage',
      'Repair',
    ],
    questions: [
      LessonQuestion(
        prompt: 'What is a mutation?',
        choices: [
          'A change in DNA',
          'A type of scan',
          'A body system',
          'A kind of swelling',
        ],
        correctIndex: 0,
      ),
      LessonQuestion(
        prompt: 'What does inheritance mean here?',
        choices: [
          'Receiving genes or traits from parents',
          'Getting medicine from a store',
          'Breaking down food',
          'Losing weight quickly',
        ],
        correctIndex: 0,
      ),
      LessonQuestion(
        prompt: 'Why is repair important?',
        choices: [
          'Because cells try to fix DNA damage',
          'Because it changes bones into muscles',
          'Because it stops all disease forever',
          'Because it is the same as metastasis',
        ],
        correctIndex: 0,
      ),
    ],
  ),
  LessonContent(
    unitNumber: 5,
    unitTitle: 'Basic Disease Terms',
    title: 'Unit 5: Symptoms and body changes',
    sourceTitle: '''MedlinePlus � Inflammation
MedlinePlus � Jaundice''',
    sourceUrl: '''https://medlineplus.gov/inflammation.html
https://medlineplus.gov/jaundice.html''',
    sourceCredit: 'Adapted from MedlinePlus in simpler language.',
    prompt: 'A new learner also needs common disease words and symptom words.',
    readingText:
        'A disease or disorder is a health problem that changes how the body works. Some diseases are caused by infection, while others are not. Inflammation is a body response to injury or infection and can lead to pain and swelling. Jaundice means yellowing of the skin or eyes. Weight loss can also be a sign that the body is under stress or not getting enough nutrition. These words do not name one single disease, but they help people describe what is happening in the body.',
    keyTerms: [
      'Disease',
      'Disorder',
      'Infection',
      'Inflammation',
      'Pain',
      'Swelling',
      'Jaundice',
      'Weight loss',
    ],
    questions: [
      LessonQuestion(
        prompt: 'What is inflammation?',
        choices: [
          'A body response to injury or infection',
          'A kind of surgery',
          'A normal chromosome',
          'A digestive enzyme',
        ],
        correctIndex: 0,
      ),
      LessonQuestion(
        prompt: 'What does jaundice describe?',
        choices: [
          'Yellowing of the skin or eyes',
          'A broken bone',
          'A type of blood test',
          'A healthy cell membrane',
        ],
        correctIndex: 0,
      ),
      LessonQuestion(
        prompt: 'What is an infection?',
        choices: [
          'A disease caused by germs',
          'Any operation done by a doctor',
          'A family history',
          'A way cells divide',
        ],
        correctIndex: 0,
      ),
    ],
  ),
  LessonContent(
    unitNumber: 6,
    unitTitle: 'Basic Diagnosis',
    title: 'Unit 6: Tests and finding a diagnosis',
    sourceTitle: '''NCI Dictionary of Cancer Terms � biopsy
NCI Dictionary of Cancer Terms � CT scan
NCI Dictionary of Cancer Terms � MRI''',
    sourceUrl:
        '''https://www.cancer.gov/publications/dictionaries/cancer-terms/def/biopsy
https://www.cancer.gov/publications/dictionaries/cancer-terms/def/ct-scan
https://www.cancer.gov/publications/dictionaries/cancer-terms/def/mri''',
    sourceCredit: 'Adapted from NCI in simpler language.',
    prompt:
        'This unit explains the very basic words used when doctors look for answers.',
    readingText:
        'Doctors use tests to learn what is happening in the body. A scan is a picture made with a machine, and imaging is the general word for making those pictures. A blood test uses a blood sample. A biopsy uses a small tissue or cell sample. Salivary testing means testing saliva, or spit, for useful information. All of these tools can help with diagnosis, which means finding out what disease or condition a person has.',
    keyTerms: [
      'Test',
      'Scan',
      'Imaging',
      'Blood test',
      'Biopsy',
      'Sample',
      'Salivary testing',
      'Diagnosis',
    ],
    questions: [
      LessonQuestion(
        prompt: 'What is a biopsy?',
        choices: [
          'A small tissue or cell sample taken for testing',
          'A kind of hormone',
          'A way to stop all pain right away',
          'A type of family history',
        ],
        correctIndex: 0,
      ),
      LessonQuestion(
        prompt: 'What does diagnosis mean?',
        choices: [
          'Finding out what disease or condition a person has',
          'Making food easier to digest',
          'Turning a benign tumor into a malignant one',
          'Teaching a cell to divide',
        ],
        correctIndex: 0,
      ),
      LessonQuestion(
        prompt: 'What is imaging?',
        choices: [
          'Making pictures of the inside of the body',
          'Writing down genes with a pencil',
          'A type of infection',
          'A hormone made by the pancreas',
        ],
        correctIndex: 0,
      ),
    ],
  ),
  LessonContent(
    unitNumber: 7,
    unitTitle: 'Basic Treatment',
    title: 'Unit 7: Ways doctors treat disease',
    sourceTitle: '''NCI Dictionary of Cancer Terms � treatment
NCI Dictionary of Cancer Terms � chemotherapy
NCI Dictionary of Cancer Terms � radiation therapy''',
    sourceUrl:
        '''https://www.cancer.gov/publications/dictionaries/cancer-terms/def/treatment
https://www.cancer.gov/publications/dictionaries/cancer-terms/def/chemotherapy
https://www.cancer.gov/publications/dictionaries/cancer-terms/def/radiation-therapy''',
    sourceCredit: 'Adapted from NCI in simpler language.',
    prompt:
        'After diagnosis comes treatment. This unit keeps those treatment words simple.',
    readingText:
        'Treatment is care used to help a disease or condition. Surgery is treatment done with an operation. Medicine is a drug used to help the body. Chemotherapy is a kind of medicine used to kill cancer cells or slow their growth. Radiation is high-energy treatment used against some cancers. Therapy is a broad word for treatment, and recovery means getting better after illness or treatment. Different people may need different treatments depending on the disease and how far it has gone.',
    keyTerms: [
      'Treatment',
      'Surgery',
      'Medicine',
      'Chemotherapy',
      'Radiation',
      'Therapy',
      'Recovery',
    ],
    questions: [
      LessonQuestion(
        prompt: 'What is chemotherapy?',
        choices: [
          'Drug treatment used to kill cancer cells or slow their growth',
          'A kind of digestive enzyme',
          'A way to measure age',
          'A type of family history',
        ],
        correctIndex: 0,
      ),
      LessonQuestion(
        prompt: 'What does recovery mean?',
        choices: [
          'Getting better after illness or treatment',
          'A new kind of tumor',
          'A receptor on the cell membrane',
          'A scan of the pancreas only',
        ],
        correctIndex: 0,
      ),
      LessonQuestion(
        prompt: 'What is surgery?',
        choices: [
          'Treatment done with an operation',
          'A signal inside a cell',
          'A type of swelling',
          'A damaged gene',
        ],
        correctIndex: 0,
      ),
    ],
  ),
  LessonContent(
    unitNumber: 8,
    unitTitle: 'Basic Risk Factors',
    title: 'Unit 8: Things that can raise risk',
    sourceTitle: '''NCI Dictionary of Cancer Terms � risk factor
NCI Dictionary of Cancer Terms � smoking
MedlinePlus � Family History''',
    sourceUrl:
        '''https://www.cancer.gov/publications/dictionaries/cancer-terms/def/risk-factor
https://www.cancer.gov/publications/dictionaries/cancer-terms/def/smoking
https://medlineplus.gov/familyhistory.html''',
    sourceCredit: 'Adapted from NCI and MedlinePlus in simpler language.',
    prompt:
        'The last beginner unit explains risk factors using everyday words.',
    readingText:
        'A risk factor is something that raises the chance of getting a disease. A risk factor does not guarantee that someone will get sick, but it can make the chance higher. Smoking is one example of a risk factor for many diseases. Diet, age, and family history can matter too. Learning about risk factors is part of learning about health, because risk is about chances and patterns, not certainty.',
    keyTerms: [
      'Smoking',
      'Diet',
      'Age',
      'Family history',
      'Health',
    ],
    questions: [
      LessonQuestion(
        prompt: 'What is a risk factor?',
        choices: [
          'Something that raises the chance of disease',
          'A guarantee that disease will happen',
          'A treatment that always cures cancer',
          'A part of the cell membrane',
        ],
        correctIndex: 0,
      ),
      LessonQuestion(
        prompt: 'Which choice is listed as a risk factor in this unit?',
        choices: [
          'Smoking',
          'Mitosis',
          'Cytoplasm',
          'Enzyme',
        ],
        correctIndex: 0,
      ),
      LessonQuestion(
        prompt: 'Why is family history important?',
        choices: [
          'It can help show patterns of disease in a family',
          'It turns all benign tumors malignant',
          'It is the same thing as a biopsy',
          'It means a person must already be sick',
        ],
        correctIndex: 0,
      ),
    ],
  ),
];

List<LessonContent> lessonSequence =
    List<LessonContent>.of(bundledLessonSequence);

const LessonContent unavailableLessonContent = LessonContent(
  unitNumber: 0,
  unitTitle: 'Unavailable',
  title: 'Lesson content unavailable',
  sourceTitle: '',
  sourceUrl: '',
  sourceCredit: '',
  readingText: 'Reconnect once to download lesson content.',
  prompt: 'Lesson content is unavailable.',
  keyTerms: <String>[],
  questions: <LessonQuestion>[],
);

class LessonContent {
  const LessonContent({
    required this.unitNumber,
    required this.unitTitle,
    required this.title,
    required this.sourceTitle,
    required this.sourceUrl,
    required this.sourceCredit,
    required this.readingText,
    required this.prompt,
    required this.keyTerms,
    required this.questions,
  });

  final int unitNumber;
  final String unitTitle;
  final String title;
  final String sourceTitle;
  final String sourceUrl;
  final String sourceCredit;
  final String readingText;
  final String prompt;
  final List<String> keyTerms;
  final List<LessonQuestion> questions;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'unitNumber': unitNumber,
      'unitTitle': unitTitle,
      'title': title,
      'sourceTitle': sourceTitle,
      'sourceUrl': sourceUrl,
      'sourceCredit': sourceCredit,
      'readingText': readingText,
      'prompt': prompt,
      'keyTerms': keyTerms,
      'questions': [for (final question in questions) question.toJson()],
    };
  }

  factory LessonContent.fromJson(Map<String, dynamic> json) {
    return LessonContent(
      unitNumber: (json['unitNumber'] as num).toInt(),
      unitTitle: json['unitTitle'] as String,
      title: json['title'] as String,
      sourceTitle: json['sourceTitle'] as String,
      sourceUrl: json['sourceUrl'] as String,
      sourceCredit: json['sourceCredit'] as String,
      readingText: json['readingText'] as String,
      prompt: json['prompt'] as String,
      keyTerms: [
        for (final dynamic term in json['keyTerms'] as List<dynamic>)
          term.toString()
      ],
      questions: [
        for (final dynamic question in json['questions'] as List<dynamic>)
          LessonQuestion.fromJson(question as Map<String, dynamic>),
      ],
    );
  }
}

class LessonQuestion {
  const LessonQuestion({
    required this.prompt,
    required this.choices,
    required this.correctIndex,
  });

  final String prompt;
  final List<String> choices;
  final int correctIndex;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'prompt': prompt,
      'choices': choices,
      'correctIndex': correctIndex,
    };
  }

  factory LessonQuestion.fromJson(Map<String, dynamic> json) {
    return LessonQuestion(
      prompt: json['prompt'] as String,
      choices: [
        for (final dynamic choice in json['choices'] as List<dynamic>)
          choice.toString()
      ],
      correctIndex: (json['correctIndex'] as num).toInt(),
    );
  }
}

class LessonContentRepository {
  LessonContentRepository({required SharedPreferences preferences})
      : _preferences = preferences;

  static const String databaseUrl = String.fromEnvironment(
    'LESSON_DATABASE_URL',
    defaultValue: '',
  );
  static const String webLessonCacheUrl = String.fromEnvironment(
    'LESSON_CACHE_URL',
    defaultValue: '',
  );
  static const String _cacheKey = 'square_shooter_bio_lesson_cache_v1';
  static const String _webCachePath = 'lesson_cache.json';

  final SharedPreferences _preferences;

  Future<void> load({
    bool refreshFromDatabase = true,
    bool loadAssetCache = true,
  }) async {
    _loadCachedLessons();
    if (loadAssetCache) {
      await _loadWebCacheLessons();
    }
    if (refreshFromDatabase) {
      unawaited(this.refreshFromDatabase());
    }
  }

  Future<void> _loadWebCacheLessons() async {
    if (!kIsWeb) {
      return;
    }
    if (webLessonCacheUrl.isNotEmpty) {
      try {
        final encoded = await NetworkAssetBundle(Uri.parse(webLessonCacheUrl))
            .loadString(webLessonCacheUrl);
        final remoteWebLessons = _decodeLessons(encoded);
        if (remoteWebLessons.isNotEmpty) {
          lessonSequence = remoteWebLessons;
          await _preferences.setString(
              _cacheKey, _encodeLessons(remoteWebLessons));
          return;
        }
      } catch (_) {
        // Fall back to local web cache or bundled lessons below.
      }
    }
    try {
      final encoded =
          await NetworkAssetBundle(Uri.base).loadString(_webCachePath);
      final webCacheLessons = _decodeLessons(encoded);
      if (webCacheLessons.isEmpty) {
        return;
      }
      lessonSequence = webCacheLessons;
      await _preferences.setString(_cacheKey, _encodeLessons(webCacheLessons));
    } catch (_) {
      // Keep the bundled or cached fallback if the optional web cache is missing.
    }
  }

  Future<void> refreshFromDatabase() async {
    if (databaseUrl.isEmpty) {
      return;
    }
    try {
      final databaseLessons =
          await _fetchDatabaseLessons().timeout(const Duration(seconds: 4));
      if (databaseLessons.isEmpty) {
        return;
      }
      lessonSequence = databaseLessons;
      await _preferences.setString(_cacheKey, _encodeLessons(databaseLessons));
    } catch (_) {
      // Offline play keeps using the last valid cache, or the bundled fallback.
    }
  }

  void _loadCachedLessons() {
    final encoded = _preferences.getString(_cacheKey);
    if (encoded == null || encoded.isEmpty) {
      lessonSequence = List<LessonContent>.of(bundledLessonSequence);
      return;
    }
    try {
      final cached = _decodeLessons(encoded);
      if (cached.isNotEmpty) {
        lessonSequence = cached;
      }
    } catch (_) {
      lessonSequence = List<LessonContent>.of(bundledLessonSequence);
    }
  }

  Future<List<LessonContent>> _fetchDatabaseLessons() async {
    final rowSet = await fetchLessonRowsFromDatabase(databaseUrl);

    final questionsByUnit = <int, List<LessonQuestion>>{};
    for (final map in rowSet.questions) {
      final unitNumber = (map['lesson_unit_number'] as num).toInt();
      questionsByUnit.putIfAbsent(unitNumber, () => <LessonQuestion>[]).add(
            LessonQuestion(
              prompt: map['prompt'] as String,
              choices: _readStringList(map['choices']),
              correctIndex: (map['correct_index'] as num).toInt(),
            ),
          );
    }

    return [
      for (final map in rowSet.lessons)
        _lessonFromColumnMap(map, questionsByUnit),
    ];
  }

  static LessonContent _lessonFromColumnMap(
    Map<String, dynamic> map,
    Map<int, List<LessonQuestion>> questionsByUnit,
  ) {
    final unitNumber = (map['unit_number'] as num).toInt();
    return LessonContent(
      unitNumber: unitNumber,
      unitTitle: map['unit_title'] as String,
      title: map['title'] as String,
      sourceTitle: map['source_title'] as String,
      sourceUrl: map['source_url'] as String,
      sourceCredit: map['source_credit'] as String,
      readingText: map['reading_text'] as String,
      prompt: map['prompt'] as String,
      keyTerms: _readStringList(map['key_terms']),
      questions: questionsByUnit[unitNumber] ?? const <LessonQuestion>[],
    );
  }

  static List<String> _readStringList(Object? value) {
    if (value is List) {
      return [for (final dynamic item in value) item.toString()];
    }
    if (value is String) {
      final decoded = jsonDecode(value);
      if (decoded is List) {
        return [for (final dynamic item in decoded) item.toString()];
      }
    }
    return const <String>[];
  }

  static String _encodeLessons(List<LessonContent> lessons) {
    return jsonEncode(<String, dynamic>{
      'version': 1,
      'lessons': [for (final lesson in lessons) lesson.toJson()],
    });
  }

  static List<LessonContent> _decodeLessons(String encoded) {
    final decoded = jsonDecode(encoded);
    if (decoded is List) {
      return [
        for (final dynamic lesson in decoded)
          LessonContent.fromJson(lesson as Map<String, dynamic>),
      ];
    }
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Expected lesson cache object');
    }
    return [
      for (final dynamic lesson in decoded['lessons'] as List<dynamic>)
        LessonContent.fromJson(lesson as Map<String, dynamic>),
    ];
  }
}

class PresentedQuestion {
  PresentedQuestion({
    required this.prompt,
    required this.choices,
    required this.correctIndex,
  });

  factory PresentedQuestion.fromLessonQuestion(
      LessonQuestion question, math.Random rng) {
    final indices =
        List<int>.generate(question.choices.length, (index) => index)
          ..shuffle(rng);
    final shuffledChoices = [
      for (final index in indices) question.choices[index]
    ];
    return PresentedQuestion(
      prompt: question.prompt,
      choices: shuffledChoices,
      correctIndex: indices.indexOf(question.correctIndex),
    );
  }

  final String prompt;
  final List<String> choices;
  final int correctIndex;
}

enum LessonOverlayStep { chest, reading, questions, results }

class LevelLessonSession {
  LevelLessonSession.forRound({
    required this.roundNumber,
    required this.lesson,
    required math.Random rng,
    this.requiresChest = false,
  })  : presentedQuestions = [
          for (final question in lesson.questions)
            PresentedQuestion.fromLessonQuestion(question, rng),
        ],
        selectedAnswers = List<int?>.filled(lesson.questions.length, null);

  final int roundNumber;
  final LessonContent lesson;
  final bool requiresChest;
  final List<PresentedQuestion> presentedQuestions;
  final List<int?> selectedAnswers;

  late LessonOverlayStep step =
      requiresChest ? LessonOverlayStep.chest : LessonOverlayStep.reading;
  int questionIndex = 0;
  int correctCount = 0;
  String resultTitle = '';
  String resultSummary = '';
  QuizDraftProfile? draftProfile;
  List<BuildOffer> chestOffers = <BuildOffer>[];
  String chestTitle = '';
  String chestSummary = '';
  bool chestResolved = false;
  List<BuildOffer> draftOffers = <BuildOffer>[];
  bool draftResolved = false;
  bool draftSkipped = false;
  bool draftRerolled = false;
  final Set<SupportOptionType> purchasedSupportOptions = <SupportOptionType>{};
}

/*
class UpgradeState {
  UpgradeState({
    required this.id,
    required this.title,
    required this.description,
    required this.baseCost,
    required this.costScale,
  });

  final String id;
  final String title;
  final String description;
  final int baseCost;
  final double costScale;
  int level = 0;
}

enum WeaponType {
  standard(
    title: 'Starter Blaster',
    description: 'Fast single shots. Reliable and simple.',
    purchaseCost: 0,
  ),
  scatter(
    title: 'Scatter Shot',
    description: 'Fires a cone of pellets for close-range crowd clearing.',
    purchaseCost: 40,
  ),
  homing(
    title: 'Homing Shot',
    description: 'Seeker rounds bend toward enemies.',
    purchaseCost: 55,
  ),
  heavy(
    title: 'Heavy Shot',
    description: 'Huge cannon rounds with strong damage and knockback feel.',
    purchaseCost: 65,
  ),
  twin(
    title: 'Twin Shot',
    description: 'Two side-by-side bullets every attack.',
    purchaseCost: 55,
  ),
  burst(
    title: 'Burst Cannon',
    description: 'Fires a tight burst of quick bullets.',
    purchaseCost: 60,
  ),
  pierce(
    title: 'Pierce Rifle',
    description: 'Rail-like shots pass through multiple enemies.',
    purchaseCost: 70,
  ),
  sniper(
    title: 'Sniper Lance',
    description: 'Very fast, very hard-hitting precision shots.',
    purchaseCost: 80,
  ),
  nova(
    title: 'Nova Ring',
    description: 'Shoots a circular burst around the player, like a survival arena weapon.',
    purchaseCost: 85,
  );

  const WeaponType({
    required this.title,
    required this.description,
    required this.purchaseCost,
  });

  final String title;
  final String description;
  final int purchaseCost;
}

class WeaponState {
  WeaponState({required this.type, this.unlocked = false});

  final WeaponType type;
  bool unlocked;
  int specialLevel = 0;
}

enum EnemyArchetype {
  swarm(
    label: 'Swarm',
    color: Color(0xFFFF5D5D),
    baseHealth: 1,
    healthVariance: 1,
    baseSpeed: 130,
    speedVariance: 45,
    baseSize: 16,
    sizeVariance: 5,
    coinValue: 1,
  ),
  rainbow(
    label: 'Rainbow',
    color: Color(0xFFFFFFFF),
    baseHealth: 3,
    healthVariance: 1,
    baseSpeed: 112,
    speedVariance: 24,
    baseSize: 18,
    sizeVariance: 4,
    coinValue: 12,
  ),
  runner(
    label: 'Runner',
    color: Color(0xFFFFB020),
    baseHealth: 2,
    healthVariance: 1,
    baseSpeed: 102,
    speedVariance: 32,
    baseSize: 22,
    sizeVariance: 6,
    coinValue: 2,
  ),
  tank(
    label: 'Tank',
    color: Color(0xFF9B5DE5),
    baseHealth: 6,
    healthVariance: 2,
    baseSpeed: 58,
    speedVariance: 14,
    baseSize: 30,
    sizeVariance: 10,
    coinValue: 3,
  ),
  stalker(
    label: 'Stalker',
    color: Color(0xFF2EC4B6),
    baseHealth: 4,
    healthVariance: 2,
    baseSpeed: 84,
    speedVariance: 20,
    baseSize: 24,
    sizeVariance: 8,
    coinValue: 2,
  );

  const EnemyArchetype({
    required this.label,
    required this.color,
    required this.baseHealth,
    required this.healthVariance,
    required this.baseSpeed,
    required this.speedVariance,
    required this.baseSize,
    required this.sizeVariance,
    required this.coinValue,
  });

  final String label;
  final Color color;
  final int baseHealth;
  final int healthVariance;
  final double baseSpeed;
  final double speedVariance;
  final double baseSize;
  final double sizeVariance;
  final int coinValue;
}

class SquareShooterGame extends FlameGame with KeyboardEvents {
  SquareShooterGame();

  final math.Random rng = math.Random();
  final ValueNotifier<int> uiTick = ValueNotifier<int>(0);
  final Set<LogicalKeyboardKey> _keysPressed = <LogicalKeyboardKey>{};

  PlayerComponent? player;
  Vector2 touchDirection = Vector2.zero();

  final Map<String, UpgradeState> upgrades = {
    'moveSpeed': UpgradeState(
      id: 'moveSpeed',
      title: 'Movement Speed',
      description: 'Run faster so you can kite dense waves.',
      baseCost: 28,
      costScale: 1.46,
    ),
    'attackSpeed': UpgradeState(
      id: 'attackSpeed',
      title: 'Attack Speed',
      description: 'Lower your base time between attacks.',
      baseCost: 32,
      costScale: 1.50,
    ),
    'reloadSpeed': UpgradeState(
      id: 'reloadSpeed',
      title: 'Reload Speed',
      description: 'Reduce weapon downtime after its own firing pattern.',
      baseCost: 36,
      costScale: 1.54,
    ),
  };

  final Map<WeaponType, WeaponState> weaponStates = {
    for (final weapon in WeaponType.values)
      weapon: WeaponState(type: weapon, unlocked: weapon == WeaponType.standard),
  };

  int credits = 0;
  int kills = 0;
  int lives = 3;
  int currentRound = 1;
  int checkpointRound = 1;
  int totalCoinsCollected = 0;
  double survivalTime = 0;
  double enemyFrenzyTimer = 0;
  double bannerTimer = 0;
  double _enemySpawnTimer = 0;
  double _enemySpawnInterval = 0.45;
  double _uiRefreshTimer = 0;
  String? bannerText;

  int enemiesSpawnedThisRound = 0;
  int enemiesDefeatedThisRound = 0;
  int enemiesTargetThisRound = 18;
  bool roundBossRequired = false;
  bool roundBossSpawned = false;
  bool roundComplete = false;

  bool _initialized = false;
  bool onTitleScreen = true;
  bool runStarted = false;
  bool pausedForLevel = false;
  bool pausedForMenu = false;
  bool gameOver = false;
  bool tutorialSeen = false;
  bool startAfterTutorial = false;

  WeaponType activeWeapon = WeaponType.standard;
  WeaponType? lockedWeaponChoice;
  int defeatedBossCount = 0;
  List<WeaponType> currentWeaponOffers = [];

  LevelLessonSession? currentLessonSession;
  int lessonCursor = 0;
  int checkpointLessonCursor = 0;

  bool get isReady => player != null;
  bool get isGameplayActive =>
      runStarted && !onTitleScreen && !pausedForLevel && !pausedForMenu && !gameOver;
  bool get enemyFrenzyActive => enemyFrenzyTimer > 0;
  bool get bossActive => children.whereType<BossComponent>().isNotEmpty;
  double get playAreaTop => 118;
  LessonContent get currentCourseLesson => lessonSequence[lessonCursor.clamp(0, lessonSequence.length - 1).toInt()];
  LessonContent get checkpointCourseLesson => lessonSequence[checkpointLessonCursor.clamp(0, lessonSequence.length - 1).toInt()];
  int get totalThreatsThisRound => enemiesTargetThisRound + (roundBossRequired ? 1 : 0);
  int get roundProgressCount => enemiesDefeatedThisRound.clamp(0, totalThreatsThisRound).toInt();
  double get levelProgress => totalThreatsThisRound <= 0 ? 0.0 : roundProgressCount / totalThreatsThisRound;
  double get enemySpeedMultiplier => enemyFrenzyActive ? 1.22 : 1.0;
  int get enemyHealthBonus => enemyFrenzyActive ? 1 : 0;
  List<WeaponType> get unlockedWeapons => WeaponType.values.where((weapon) => weaponStates[weapon]!.unlocked).toList();
  WeaponState get activeWeaponState => weaponStates[activeWeapon]!;
  bool get weaponPathLocked => lockedWeaponChoice != null;

  bool isWeaponShopRound(int roundNumber) => roundNumber % 3 == 0;

  bool get currentRoundUsesWeaponShop => isWeaponShopRound(currentRound);

  double gameYSpawn(double entitySize) {
    final minY = playAreaTop;
    final maxY = math.max(minY, size.y - entitySize);
    return minY + rng.nextDouble() * math.max(1.0, maxY - minY);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (!_initialized && size.x > 0 && size.y > 0) {
      _initialized = true;
      _resetRunState(showTitle: true);
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawColor(const Color(0xFF09101D), BlendMode.srcOver);
    final backgroundPaint = Paint()..color = const Color(0xFF15233D);
    const gridSize = 32.0;
    for (double x = 0; x <= size.x; x += gridSize) {
      canvas.drawRect(Rect.fromLTWH(x, 0, 1, size.y), backgroundPaint);
    }
    for (double y = 0; y <= size.y; y += gridSize) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.x, 1), backgroundPaint);
    }
    super.render(canvas);
  }

  @override
  void update(double dt) {
    if (enemyFrenzyTimer > 0) {
      enemyFrenzyTimer = math.max(0.0, enemyFrenzyTimer - dt);
    }
    if (bannerTimer > 0) {
      bannerTimer = math.max(0.0, bannerTimer - dt);
      if (bannerTimer <= 0) {
        bannerText = null;
      }
    }

    if (isGameplayActive) {
      survivalTime += dt;
      _enemySpawnTimer += dt;
      _uiRefreshTimer += dt;

      final spawnFactor = enemyFrenzyActive ? 0.88 : 1.0;
      _enemySpawnInterval = math.max(0.14, (0.46 - currentRound * 0.012) * spawnFactor);
      while (!roundComplete && enemiesSpawnedThisRound < enemiesTargetThisRound && _enemySpawnTimer >= _enemySpawnInterval) {
        _enemySpawnTimer -= _enemySpawnInterval;
        spawnEnemy();
        enemiesSpawnedThisRound += 1;
      }

      _maybeSpawnBoss();
      _handleManualCollisions();
      _maybeFinishRound();

      if (_uiRefreshTimer >= 0.1) {
        _uiRefreshTimer = 0;
        notifyUi();
      }
    }

    super.update(dt);
  }

  void _resetRunState({required bool showTitle, bool preserveCourseProgress = false}) {
    for (final component in children.toList()) {
      component.removeFromParent();
    }

    credits = 0;
    kills = 0;
    lives = 3;
    currentRound = preserveCourseProgress ? checkpointRound : 1;
    checkpointRound = preserveCourseProgress ? checkpointRound : 1;
    totalCoinsCollected = 0;
    survivalTime = 0;
    enemyFrenzyTimer = 0;
    bannerTimer = 0;
    bannerText = null;
    _enemySpawnTimer = 0;
    _enemySpawnInterval = 0.45;
    _uiRefreshTimer = 0;
    enemiesSpawnedThisRound = 0;
    enemiesDefeatedThisRound = 0;
    enemiesTargetThisRound = 18;
    roundBossRequired = false;
    roundBossSpawned = false;
    roundComplete = false;
    defeatedBossCount = 0;
    currentWeaponOffers = [];
    currentLessonSession = null;
    pausedForLevel = false;
    pausedForMenu = false;
    gameOver = false;
    if (!preserveCourseProgress) {
      lessonCursor = 0;
      checkpointLessonCursor = 0;
    } else {
      lessonCursor = checkpointLessonCursor;
    }
    runStarted = !showTitle;
    onTitleScreen = showTitle;
    startAfterTutorial = false;
    touchDirection = Vector2.zero();
    _keysPressed.clear();

    activeWeapon = WeaponType.standard;
    lockedWeaponChoice = null;
    for (final upgrade in upgrades.values) {
      upgrade.level = 0;
    }
    for (final state in weaponStates.values) {
      state.unlocked = state.type == WeaponType.standard;
      state.specialLevel = 0;
    }

    player = PlayerComponent(
      position: Vector2(size.x / 2 - 14, size.y / 2 - 14),
    );
    add(player!);

    overlays.remove(LevelOverlay.id);
    overlays.remove(GameOverOverlay.id);
    overlays.remove(TutorialOverlay.id);
    overlays.remove(WeaponSelectOverlay.id);
    overlays.remove(WeaponUpgradeOverlay.id);
    if (!overlays.isActive(HudOverlay.id)) {
      overlays.add(HudOverlay.id);
    }
    if (showTitle) {
      if (!overlays.isActive(TitleOverlay.id)) {
        overlays.add(TitleOverlay.id);
      }
    } else {
      overlays.remove(TitleOverlay.id);
    }

    _prepareRound(currentRound);
    notifyUi();
  }

  void startFromTitle({bool freshCourse = false}) {
    _resetRunState(showTitle: false, preserveCourseProgress: !freshCourse);
  }

  void startFreshCourse() {
    startFromTitle(freshCourse: true);
  }

  void handleTitleStart() {
    if (tutorialSeen) {
      startFromTitle();
    } else {
      startAfterTutorial = true;
      openTutorial();
    }
  }

  void restartGame() {
    _resetRunState(showTitle: false, preserveCourseProgress: true);
  }

  void returnToTitle() {
    _resetRunState(showTitle: true, preserveCourseProgress: true);
  }

  void _prepareRound(int roundNumber) {
    enemiesSpawnedThisRound = 0;
    enemiesDefeatedThisRound = 0;
    enemiesTargetThisRound = 18 + roundNumber * 5;
    roundComplete = false;
    roundBossSpawned = false;
    roundBossRequired = roundNumber % 3 == 0;
    _enemySpawnTimer = 0;
    showBanner('Round $roundNumber start', duration: 2.0);
  }

  void _rollWeaponOffers() {
    if (!currentRoundUsesWeaponShop || weaponPathLocked) {
      currentWeaponOffers = [];
      return;
    }
    final pool = WeaponType.values.where((weapon) => weapon != WeaponType.standard && !weaponStates[weapon]!.unlocked).toList();
    pool.shuffle(rng);
    currentWeaponOffers = pool.take(math.min(3, pool.length)).toList();
  }

  Vector2 get moveInput {
    final keyboard = Vector2.zero();
    if (_keysPressed.contains(LogicalKeyboardKey.keyA) || _keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      keyboard.x -= 1;
    }
    if (_keysPressed.contains(LogicalKeyboardKey.keyD) || _keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      keyboard.x += 1;
    }
    if (_keysPressed.contains(LogicalKeyboardKey.keyW) || _keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      keyboard.y -= 1;
    }
    if (_keysPressed.contains(LogicalKeyboardKey.keyS) || _keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      keyboard.y += 1;
    }
    final combined = keyboard + touchDirection;
    if (combined.length2 > 1) {
      combined.normalize();
    }
    return combined;
  }

  void setTouchDirection(Vector2 direction) {
    touchDirection = direction;
  }

  void triggerDash() {
    if (isGameplayActive) {
      player?.tryDash();
      notifyUi();
    }
  }

  EnemyArchetype _pickEnemyArchetype() {
    final roll = rng.nextDouble();
    if (roll < 0.03) {
      return EnemyArchetype.rainbow;
    }
    if (roll < 0.34) {
      return EnemyArchetype.swarm;
    }
    if (roll < 0.60) {
      return EnemyArchetype.runner;
    }
    if (roll < 0.82) {
      return EnemyArchetype.stalker;
    }
    return EnemyArchetype.tank;
  }

  void spawnEnemy() {
    final archetype = _pickEnemyArchetype();
    final enemySize = archetype.baseSize + rng.nextDouble() * archetype.sizeVariance;
    late Vector2 spawn;
    final spawnMargin = enemySize + 8;
    switch (rng.nextInt(4)) {
      case 0:
        spawn = Vector2(-spawnMargin, gameYSpawn(enemySize));
        break;
      case 1:
        spawn = Vector2(size.x + spawnMargin, gameYSpawn(enemySize));
        break;
      case 2:
        spawn = Vector2(rng.nextDouble() * math.max(1.0, size.x - enemySize), playAreaTop - spawnMargin);
        break;
      default:
        spawn = Vector2(rng.nextDouble() * math.max(1.0, size.x - enemySize), size.y + spawnMargin);
        break;
    }

    final hp = archetype.baseHealth + rng.nextInt(archetype.healthVariance + 1) + enemyHealthBonus + currentRound ~/ 3;
    final speed = archetype.baseSpeed + rng.nextDouble() * archetype.speedVariance + currentRound * 1.8;
    add(
      EnemyComponent(
        archetype: archetype,
        position: spawn,
        size: Vector2.all(enemySize),
        baseSpeed: speed,
        health: hp,
      ),
    );
  }

  void _spawnBoss() {
    final bossSize = 90.0;
    late Vector2 spawn;
    switch (rng.nextInt(4)) {
      case 0:
        spawn = Vector2(-bossSize, gameYSpawn(bossSize));
        break;
      case 1:
        spawn = Vector2(size.x + bossSize, gameYSpawn(bossSize));
        break;
      case 2:
        spawn = Vector2(rng.nextDouble() * math.max(40.0, size.x - bossSize), playAreaTop - bossSize);
        break;
      default:
        spawn = Vector2(rng.nextDouble() * math.max(40.0, size.x - bossSize), size.y + bossSize);
        break;
    }
    add(
      BossComponent(
        accentColor: const Color(0xFFFF6B6B),
        position: spawn,
        size: Vector2.all(bossSize),
        maxHealth: 40 + currentRound * 8,
        health: 40 + currentRound * 8,
        baseSpeed: 72 + currentRound * 2.5,
        coinValue: 18 + currentRound * 2,
      ),
    );
  }

  void _maybeSpawnBoss() {
    if (gameOver || onTitleScreen || pausedForLevel || bossActive || roundComplete) {
      return;
    }
    if (!roundBossRequired || roundBossSpawned) {
      return;
    }
    if (enemiesSpawnedThisRound < enemiesTargetThisRound) {
      return;
    }
    if (children.whereType<EnemyComponent>().isNotEmpty) {
      return;
    }
    roundBossSpawned = true;
    showBanner('Boss wave incoming', duration: 2.6);
    _spawnBoss();
  }

  void spawnCoin(Vector2 position, int value) {
    add(CoinComponent(position: position.clone(), value: value));
  }

  Vector2? nearestThreatCenterTo(Vector2 from) {
    Vector2? best;
    double bestDistance = double.infinity;
    for (final enemy in children.whereType<EnemyComponent>()) {
      final distance = enemy.center.distanceToSquared(from);
      if (distance < bestDistance) {
        bestDistance = distance;
        best = enemy.center;
      }
    }
    for (final boss in children.whereType<BossComponent>()) {
      final distance = boss.center.distanceToSquared(from);
      if (distance < bestDistance) {
        bestDistance = distance;
        best = boss.center;
      }
    }
    return best;
  }

  bool canAffordWeapon(WeaponType weapon) {
    if (weaponPathLocked || !currentRoundUsesWeaponShop || !currentWeaponOffers.contains(weapon)) {
      return false;
    }
    final state = weaponStates[weapon]!;
    return !state.unlocked && credits >= weapon.purchaseCost;
  }

  void buyWeapon(WeaponType weapon) {
    final state = weaponStates[weapon]!;
    if (state.unlocked || credits < weapon.purchaseCost || weaponPathLocked || !currentRoundUsesWeaponShop || !currentWeaponOffers.contains(weapon)) {
      return;
    }
    credits -= weapon.purchaseCost;
    state.unlocked = true;
    activeWeapon = weapon;
    if (weapon != WeaponType.standard) {
      lockedWeaponChoice = weapon;
      for (final other in WeaponType.values) {
        if (other != weapon && other != WeaponType.standard) {
          weaponStates[other]!.unlocked = false;
        }
      }
      showBanner('${weapon.title} chosen. Other weapon paths locked for this run.', duration: 3.0);
    } else {
      showBanner('${weapon.title} equipped.', duration: 2.0);
    }
    notifyUi();
  }

  void equipWeapon(WeaponType weapon) {
    if (!weaponStates[weapon]!.unlocked) {
      return;
    }
    if (weaponPathLocked && weapon != lockedWeaponChoice) {
      return;
    }
    activeWeapon = weapon;
    showBanner('Equipped ${weapon.title}', duration: 1.8);
    notifyUi();
  }

  void openTutorial() {
    if (overlays.isActive(TutorialOverlay.id)) {
      return;
    }
    if (!onTitleScreen) {
      pausedForMenu = true;
    }
    overlays.add(TutorialOverlay.id);
    notifyUi();
  }

  void closeTutorial() {
    if (!overlays.isActive(TutorialOverlay.id)) {
      return;
    }
    overlays.remove(TutorialOverlay.id);
    tutorialSeen = true;
    final shouldStart = startAfterTutorial;
    startAfterTutorial = false;
    if (shouldStart) {
      startFromTitle();
      return;
    }
    if (!onTitleScreen) {
      pausedForMenu = false;
    }
    notifyUi();
  }

  void openWeaponSelect() {}

  void closeWeaponSelect() {
    overlays.remove(WeaponSelectOverlay.id);
    pausedForMenu = false;
    notifyUi();
  }

  void openWeaponUpgrade() {}

  void closeWeaponUpgrade() {
    overlays.remove(WeaponUpgradeOverlay.id);
    pausedForMenu = false;
    notifyUi();
  }

  int specialUpgradeCost(WeaponType weapon) {
    final state = weaponStates[weapon]!;
    return 20 + weapon.index * 8 + state.specialLevel * 16;
  }

  bool canAffordWeaponUpgrade(WeaponType weapon) {
    return weaponStates[weapon]!.unlocked && credits >= specialUpgradeCost(weapon);
  }

  void buyWeaponSpecialUpgrade(WeaponType weapon) {
    final state = weaponStates[weapon]!;
    final cost = specialUpgradeCost(weapon);
    if (!state.unlocked || credits < cost) {
      return;
    }
    credits -= cost;
    state.specialLevel += 1;
    showBanner('${weapon.title} upgraded to Lv.${state.specialLevel}', duration: 2.2);
    notifyUi();
  }

  String weaponSpecialSummary(WeaponType weapon) {
    final level = weaponStates[weapon]!.specialLevel;
    switch (weapon) {
      case WeaponType.standard:
        return 'Lv.$level · modest bullet speed and damage boosts.';
      case WeaponType.scatter:
        return 'Lv.$level · more pellets and tighter spread.';
      case WeaponType.homing:
        return 'Lv.$level · stronger tracking and better damage.';
      case WeaponType.heavy:
        return 'Lv.$level · larger rounds with even higher impact.';
      case WeaponType.twin:
        return 'Lv.$level · wider side bullets and stronger pair damage.';
      case WeaponType.burst:
        return 'Lv.$level · larger burst size and less delay between bursts.';
      case WeaponType.pierce:
        return 'Lv.$level · more pierce and stronger rail damage.';
      case WeaponType.sniper:
        return 'Lv.$level · bigger critical-style damage and faster bolts.';
      case WeaponType.nova:
        return 'Lv.$level · more shards in every ring and higher shard damage.';
    }
  }

  void showBanner(String text, {double duration = 2.4}) {
    bannerText = text;
    bannerTimer = duration;
    notifyUi();
  }

  Vector2 _rotateVector(Vector2 input, double radians) {
    final cosTheta = math.cos(radians);
    final sinTheta = math.sin(radians);
    return Vector2(
      input.x * cosTheta - input.y * sinTheta,
      input.x * sinTheta + input.y * cosTheta,
    );
  }

  BulletComponent _makeBullet({
    required Vector2 origin,
    required Vector2 direction,
    required int damage,
    required double speed,
    required double bulletSize,
    double homingStrength = 0,
    int pierce = 0,
    Color color = const Color(0xFFB9FBC0),
  }) {
    return BulletComponent(
      position: origin,
      direction: direction.normalized(),
      damage: damage,
      speed: speed,
      bulletSize: bulletSize,
      homingStrength: homingStrength,
      remainingHits: pierce,
      tint: color,
    );
  }

  double fireWeapon(Vector2 origin, Vector2 direction) {
    if (direction.length2 == 0) {
      return (player?.fireCooldown ?? 0.38) * (player?.reloadMultiplier ?? 1.0);
    }
    final currentPlayer = player;
    if (currentPlayer == null) {
      return 0.38;
    }

    final normalized = direction.normalized();
    final special = activeWeaponState.specialLevel;
    switch (activeWeapon) {
      case WeaponType.standard:
        add(_makeBullet(
          origin: origin.clone(),
          direction: normalized,
          damage: currentPlayer.bulletDamage + special ~/ 2,
          speed: 440 + special * 12,
          bulletSize: 8 + special * 0.3,
        ));
        return currentPlayer.fireCooldown * 1.0 * currentPlayer.reloadMultiplier;
      case WeaponType.scatter:
        final pelletCount = 5 + math.min(3, special ~/ 2);
        final spread = math.max(0.10, 0.34 - special * 0.015);
        final pelletDamage = math.max(1, currentPlayer.bulletDamage + special ~/ 3);
        for (int i = 0; i < pelletCount; i++) {
          final centered = i - (pelletCount - 1) / 2;
          add(_makeBullet(
            origin: origin.clone(),
            direction: _rotateVector(normalized, centered * spread),
            damage: pelletDamage,
            speed: 430 + special * 8,
            bulletSize: 6.5 + special * 0.2,
            color: const Color(0xFFFFD166),
          ));
        }
        return currentPlayer.fireCooldown * 1.16 * currentPlayer.reloadMultiplier;
      case WeaponType.homing:
        add(_makeBullet(
          origin: origin.clone(),
          direction: normalized,
          damage: currentPlayer.bulletDamage + 2 + special ~/ 2,
          speed: 450 + special * 12,
          bulletSize: 10 + special * 0.4,
          homingStrength: 7.5 + special * 1.1,
          color: const Color(0xFF9BF6FF),
        ));
        return currentPlayer.fireCooldown * 1.18 * currentPlayer.reloadMultiplier;
      case WeaponType.heavy:
        add(_makeBullet(
          origin: origin.clone(),
          direction: normalized,
          damage: currentPlayer.bulletDamage + 4 + special,
          speed: 320 + special * 10,
          bulletSize: 18 + special * 1.8,
          color: const Color(0xFFFF6B6B),
        ));
        return currentPlayer.fireCooldown * 1.30 * currentPlayer.reloadMultiplier;
      case WeaponType.twin:
        final perpendicular = Vector2(-normalized.y, normalized.x);
        final offset = 10 + special * 0.5;
        for (final sign in [-1.0, 1.0]) {
          add(_makeBullet(
            origin: origin.clone() + perpendicular * (offset * sign),
            direction: normalized,
            damage: currentPlayer.bulletDamage + 1 + special ~/ 2,
            speed: 450 + special * 10,
            bulletSize: 7.5 + special * 0.2,
            color: const Color(0xFFA0C4FF),
          ));
        }
        return currentPlayer.fireCooldown * 1.04 * currentPlayer.reloadMultiplier;
      case WeaponType.burst:
        final burstCount = 3 + math.min(2, special ~/ 3);
        for (int i = 0; i < burstCount; i++) {
          final spread = (i - (burstCount - 1) / 2) * 0.06;
          add(_makeBullet(
            origin: origin.clone(),
            direction: _rotateVector(normalized, spread),
            damage: currentPlayer.bulletDamage + 1 + special ~/ 3,
            speed: 460 + special * 8,
            bulletSize: 7 + special * 0.2,
            color: const Color(0xFF80FFDB),
          ));
        }
        return currentPlayer.fireCooldown * 1.22 * currentPlayer.reloadMultiplier;
      case WeaponType.pierce:
        add(_makeBullet(
          origin: origin.clone(),
          direction: normalized,
          damage: currentPlayer.bulletDamage + 3 + special,
          speed: 520 + special * 12,
          bulletSize: 9 + special * 0.3,
          pierce: 2 + special ~/ 2,
          color: const Color(0xFFC77DFF),
        ));
        return currentPlayer.fireCooldown * 1.26 * currentPlayer.reloadMultiplier;
      case WeaponType.sniper:
        add(_makeBullet(
          origin: origin.clone(),
          direction: normalized,
          damage: currentPlayer.bulletDamage + 7 + special * 2,
          speed: 680 + special * 20,
          bulletSize: 8 + special * 0.2,
          pierce: 1 + special ~/ 3,
          color: const Color(0xFFFFC6FF),
        ));
        return currentPlayer.fireCooldown * 1.55 * currentPlayer.reloadMultiplier;
      case WeaponType.nova:
        final shardCount = 8 + math.min(6, special);
        for (int i = 0; i < shardCount; i++) {
          final angle = (math.pi * 2 * i) / shardCount;
          add(_makeBullet(
            origin: origin.clone(),
            direction: Vector2(math.cos(angle), math.sin(angle)),
            damage: currentPlayer.bulletDamage + 1 + special ~/ 2,
            speed: 360 + special * 10,
            bulletSize: 7 + special * 0.2,
            color: const Color(0xFFFFADAD),
          ));
        }
        return currentPlayer.fireCooldown * 1.45 * currentPlayer.reloadMultiplier;
    }
  }

  void awardKill(EnemyComponent enemy) {
    kills += 1;
    enemiesDefeatedThisRound += 1;
    spawnCoin(enemy.center - Vector2.all(6), enemy.coinValue);
    notifyUi();
    _maybeFinishRound();
  }

  void awardBossKill(BossComponent boss) {
    kills += 1;
    enemiesDefeatedThisRound += 1;
    spawnCoin(boss.center - Vector2.all(10), boss.coinValue);
    defeatedBossCount += 1;
    showBanner('Boss defeated. Big coin drop.', duration: 2.8);
    notifyUi();
    _maybeFinishRound();
  }

  void addCredits(int amount) {
    credits += amount;
    totalCoinsCollected += amount;
    notifyUi();
  }

  void _collectRemainingCoins() {
    for (final coin in children.whereType<CoinComponent>().toList()) {
      credits += coin.value;
      totalCoinsCollected += coin.value;
      coin.removeFromParent();
    }
  }

  void _openRoundSummary() {
    if (pausedForLevel || gameOver || onTitleScreen) {
      return;
    }
    _collectRemainingCoins();
    _rollWeaponOffers();
    currentLessonSession = LevelLessonSession.forRound(
      roundNumber: currentRound,
      lesson: currentCourseLesson,
      rng: rng,
    );
    pausedForLevel = true;
    overlays.add(LevelOverlay.id);
    notifyUi();
  }

  void _maybeFinishRound() {
    if (roundComplete || pausedForLevel || gameOver || onTitleScreen) {
      return;
    }
    if (enemiesSpawnedThisRound < enemiesTargetThisRound) {
      return;
    }
    if (children.whereType<EnemyComponent>().isNotEmpty || children.whereType<BossComponent>().isNotEmpty) {
      return;
    }
    if (roundBossRequired && !roundBossSpawned) {
      return;
    }
    roundComplete = true;
    showBanner('Round $currentRound clear', duration: 2.2);
    _openRoundSummary();
  }

  void startLessonQuestions() {
    final session = currentLessonSession;
    if (session == null) {
      return;
    }
    session.step = LessonOverlayStep.questions;
    session.questionIndex = 0;
    notifyUi();
  }

  void selectLessonAnswer(int answerIndex) {
    final session = currentLessonSession;
    if (session == null || session.step != LessonOverlayStep.questions) {
      return;
    }
    session.selectedAnswers[session.questionIndex] = answerIndex;
    notifyUi();
  }

  void submitLessonAnswer() {
    final session = currentLessonSession;
    if (session == null || session.step != LessonOverlayStep.questions) {
      return;
    }
    final selected = session.selectedAnswers[session.questionIndex];
    if (selected == null) {
      return;
    }
    final question = session.presentedQuestions[session.questionIndex];
    if (selected == question.correctIndex) {
      session.correctCount += 1;
    }
    session.questionIndex += 1;
    if (session.questionIndex >= session.presentedQuestions.length) {
      _finalizeLessonSession();
    }
    notifyUi();
  }

  void _finalizeLessonSession() {
    final session = currentLessonSession;
    if (session == null) {
      return;
    }
    session.step = LessonOverlayStep.results;
    if (session.correctCount == 3) {
      session.discountMultiplier = 0.50;
      session.resultTitle = '3 / 3 correct';
      session.resultSummary = 'Great round. Shop prices are 50% off before the next wave.';
    } else if (session.correctCount == 2) {
      session.discountMultiplier = 0.80;
      session.resultTitle = '2 / 3 correct';
      session.resultSummary = 'Solid round. Shop prices are 20% off before the next wave.';
    } else if (session.correctCount == 1) {
      session.discountMultiplier = 1.0;
      _triggerEnemyFrenzy();
      session.resultTitle = '1 / 3 correct';
      session.resultSummary = 'No discount. The next wave gets stronger for 12 seconds.';
    } else {
      session.discountMultiplier = 1.0;
      _triggerEnemyFrenzy();
      final fee = _applyCoinFee();
      session.resultTitle = '0 / 3 correct';
      session.resultSummary = 'No discount. The next wave gets stronger for 12 seconds and you lose $fee coins.';
    }
  }

  void _triggerEnemyFrenzy() {
    enemyFrenzyTimer = 12.0;
    for (final enemy in children.whereType<EnemyComponent>()) {
      enemy.health += 1;
    }
  }

  int _applyCoinFee() {
    if (credits <= 0) {
      return 0;
    }
    final fee = math.max(5, (credits * 0.2).ceil());
    final appliedFee = math.min(fee, credits);
    credits -= appliedFee;
    return appliedFee;
  }

  int upgradeCost(String upgradeId) {
    final upgrade = upgrades[upgradeId]!;
    final scaled = upgrade.baseCost * math.pow(upgrade.costScale, upgrade.level);
    return scaled.round();
  }

  int lessonUpgradeCost(String upgradeId) {
    final session = currentLessonSession;
    final base = upgradeCost(upgradeId);
    if (session == null) {
      return base;
    }
    return math.max(1, (base * session.discountMultiplier).round());
  }

  bool canAffordLessonUpgrade(String upgradeId) {
    return credits >= lessonUpgradeCost(upgradeId);
  }

  void buyLessonUpgrade(String upgradeId) {
    final currentPlayer = player;
    final upgrade = upgrades[upgradeId];
    if (currentPlayer == null || upgrade == null) {
      return;
    }
    final price = lessonUpgradeCost(upgradeId);
    if (credits < price) {
      return;
    }
    credits -= price;
    upgrade.level += 1;
    switch (upgradeId) {
      case 'moveSpeed':
        currentPlayer.baseSpeed += 24;
        break;
      case 'attackSpeed':
        currentPlayer.fireCooldown = math.max(0.10, currentPlayer.fireCooldown * 0.90);
        break;
      case 'reloadSpeed':
        currentPlayer.reloadMultiplier = math.max(0.55, currentPlayer.reloadMultiplier * 0.92);
        break;
    }
    showBanner('${upgrade.title} upgraded to Lv.${upgrade.level}', duration: 1.8);
    notifyUi();
  }

  void skipLessonUpgrade() {
    closeLevelOverlay();
  }

  void closeLevelOverlay() {
    final hadSession = currentLessonSession != null;
    if (hadSession && lessonCursor < lessonSequence.length - 1) {
      lessonCursor += 1;
    }
    if (hadSession) {
      checkpointLessonCursor = lessonCursor;
      checkpointRound = currentRound + 1;
    }
    currentLessonSession = null;
    pausedForLevel = false;
    overlays.remove(LevelOverlay.id);
    currentRound += 1;
    _prepareRound(currentRound);
    notifyUi();
  }

  void onPlayerHit() {
    final currentPlayer = player;
    if (currentPlayer == null || gameOver || currentPlayer.invulnerableRemaining > 0) {
      return;
    }
    lives -= 1;
    if (lives <= 0) {
      lives = 0;
      gameOver = true;
      pausedForLevel = false;
      overlays.remove(LevelOverlay.id);
      overlays.remove(TitleOverlay.id);
      overlays.add(GameOverOverlay.id);
      notifyUi();
      return;
    }

    currentPlayer.position = Vector2(size.x / 2 - currentPlayer.size.x / 2, size.y / 2 - currentPlayer.size.y / 2);
    currentPlayer.invulnerableRemaining = 1.5;
    for (final enemy in children.whereType<EnemyComponent>().toList()) {
      if (enemy.center.distanceTo(currentPlayer.center) < 130) {
        enemy.removeFromParent();
      }
    }
    notifyUi();
  }

  void _handleManualCollisions() {
    final currentPlayer = player;
    if (currentPlayer == null) {
      return;
    }
    final playerRect = currentPlayer.rect;
    if (currentPlayer.invulnerableRemaining <= 0) {
      for (final enemy in children.whereType<EnemyComponent>().toList()) {
        if (playerRect.overlaps(enemy.rect)) {
          onPlayerHit();
          return;
        }
      }
      for (final boss in children.whereType<BossComponent>().toList()) {
        if (playerRect.overlaps(boss.rect)) {
          onPlayerHit();
          return;
        }
      }
    }

    for (final bullet in children.whereType<BulletComponent>().toList()) {
      var handled = false;
      for (final enemy in children.whereType<EnemyComponent>().toList()) {
        if (bullet.rect.overlaps(enemy.rect)) {
          enemy.takeDamage(bullet.damage);
          if (!bullet.registerHit()) {
            bullet.removeFromParent();
          }
          handled = true;
          break;
        }
      }
      if (handled) {
        continue;
      }
      for (final boss in children.whereType<BossComponent>().toList()) {
        if (bullet.rect.overlaps(boss.rect)) {
          boss.takeDamage(bullet.damage);
          if (!bullet.registerHit()) {
            bullet.removeFromParent();
          }
          break;
        }
      }
    }

    for (final coin in children.whereType<CoinComponent>().toList()) {
      if (playerRect.overlaps(coin.rect)) {
        addCredits(coin.value);
        coin.removeFromParent();
      }
    }
  }

  void notifyUi() {
    uiTick.value++;
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _keysPressed
      ..clear()
      ..addAll(keysPressed);

    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
      if (onTitleScreen) {
        handleTitleStart();
      }
      return KeyEventResult.handled;
    }
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.space) {
      triggerDash();
      return KeyEventResult.handled;
    }
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
      if (overlays.isActive(TutorialOverlay.id)) {
        closeTutorial();
      }
      return KeyEventResult.handled;
    }
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.keyR) {
      if (gameOver) {
        restartGame();
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.handled;
  }
}

class PlayerComponent extends PositionComponent with HasGameReference<SquareShooterGame> {
  PlayerComponent({required super.position}) : super(size: Vector2.all(28));

  double baseSpeed = 210;
  double dashSpeed = 540;
  double dashCooldown = 2.0;
  double dashCooldownRemaining = 0;
  double dashTimeRemaining = 0;
  double fireCooldown = 0.34;
  double reloadMultiplier = 1.0;
  double fireCooldownRemaining = 0;
  double invulnerableRemaining = 0;
  int bulletDamage = 1;
  Vector2 _lastNonZeroDirection = Vector2(1, 0);

  Rect get rect => Rect.fromLTWH(position.x, position.y, size.x, size.y);
  Vector2 get center => position + size / 2;

  @override
  void render(Canvas canvas) {
    final flashing = invulnerableRemaining > 0 && (invulnerableRemaining * 8).floor().isEven;
    final color = flashing
        ? const Color(0xFFE5E7EB)
        : dashTimeRemaining > 0
            ? const Color(0xFF00E5FF)
            : const Color(0xFF4D7CFE);
    final paint = Paint()..color = color;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), paint);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (dashCooldownRemaining > 0) {
      dashCooldownRemaining = math.max(0.0, dashCooldownRemaining - dt);
    }
    if (dashTimeRemaining > 0) {
      dashTimeRemaining = math.max(0.0, dashTimeRemaining - dt);
    }
    if (fireCooldownRemaining > 0) {
      fireCooldownRemaining = math.max(0.0, fireCooldownRemaining - dt);
    }
    if (invulnerableRemaining > 0) {
      invulnerableRemaining = math.max(0.0, invulnerableRemaining - dt);
    }
    if (!game.isGameplayActive) {
      return;
    }

    final move = game.moveInput;
    if (move.length2 > 0) {
      _lastNonZeroDirection = move.normalized();
    }
    final speed = dashTimeRemaining > 0 ? dashSpeed : baseSpeed;
    final movementDirection = move.length2 > 0 ? move : (dashTimeRemaining > 0 ? _lastNonZeroDirection : Vector2.zero());
    position += movementDirection * speed * dt;
    position.x = position.x.clamp(0.0, math.max(0.0, game.size.x - size.x)).toDouble();
    position.y = position.y.clamp(game.playAreaTop, math.max(game.playAreaTop, game.size.y - size.y)).toDouble();

    if (fireCooldownRemaining <= 0) {
      final targetCenter = game.nearestThreatCenterTo(center);
      if (targetCenter != null) {
        final aim = targetCenter - center;
        if (aim.length2 > 0) {
          fireCooldownRemaining = game.fireWeapon(center - Vector2.all(4), aim);
        }
      }
    }
  }

  void tryDash() {
    if (dashCooldownRemaining > 0) {
      return;
    }
    final move = game.moveInput;
    if (move.length2 == 0 && _lastNonZeroDirection.length2 == 0) {
      return;
    }
    dashCooldownRemaining = dashCooldown;
    dashTimeRemaining = 0.16;
  }
}

class EnemyComponent extends PositionComponent with HasGameReference<SquareShooterGame> {
  EnemyComponent({
    required this.archetype,
    required super.position,
    required super.size,
    required this.baseSpeed,
    required this.health,
  });

  final EnemyArchetype archetype;
  final double baseSpeed;
  int health;

  Rect get rect => Rect.fromLTWH(position.x, position.y, size.x, size.y);
  Vector2 get center => position + size / 2;
  int get coinValue => archetype.coinValue;

  @override
  void render(Canvas canvas) {
    if (archetype == EnemyArchetype.rainbow) {
      final rainbowColors = [
        const Color(0xFFFF0000),
        const Color(0xFFFF8C00),
        const Color(0xFFFFFF00),
        const Color(0xFF00C853),
        const Color(0xFF2196F3),
        const Color(0xFF9C27B0),
      ];
      final stripeWidth = size.x / rainbowColors.length;
      for (int i = 0; i < rainbowColors.length; i++) {
        canvas.drawRect(
          Rect.fromLTWH(i * stripeWidth, 0, stripeWidth + 1, size.y),
          Paint()..color = rainbowColors[i],
        );
      }
    } else {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), Paint()..color = archetype.color);
    }
    final hpFraction = (health.clamp(0, 10)) / 10;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x * hpFraction, 4), Paint()..color = const Color(0xFF111827));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.isGameplayActive) {
      return;
    }
    final currentPlayer = game.player;
    if (currentPlayer == null) {
      return;
    }
    final toPlayer = currentPlayer.center - center;
    if (toPlayer.length2 > 0) {
      position += toPlayer.normalized() * baseSpeed * game.enemySpeedMultiplier * dt;
    }
    position.x = position.x.clamp(0.0, math.max(0.0, game.size.x - size.x)).toDouble();
    position.y = position.y.clamp(game.playAreaTop, math.max(game.playAreaTop, game.size.y - size.y)).toDouble();
  }

  void takeDamage(int amount) {
    health -= amount;
    if (health <= 0) {
      game.awardKill(this);
      removeFromParent();
    }
  }
}

class BossComponent extends PositionComponent with HasGameReference<SquareShooterGame> {
  BossComponent({
    required this.accentColor,
    required super.position,
    required super.size,
    required this.maxHealth,
    required this.health,
    required this.baseSpeed,
    required this.coinValue,
  });

  final Color accentColor;
  final int maxHealth;
  int health;
  final double baseSpeed;
  final int coinValue;

  Rect get rect => Rect.fromLTWH(position.x, position.y, size.x, size.y);
  Vector2 get center => position + size / 2;

  @override
  void render(Canvas canvas) {
    final path = Path()
      ..moveTo(size.x / 2, 0)
      ..lineTo(size.x, size.y)
      ..lineTo(0, size.y)
      ..close();
    canvas.drawPath(path, Paint()..color = accentColor);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    final hpFraction = health <= 0 ? 0.0 : (health / maxHealth).clamp(0.0, 1.0).toDouble();
    canvas.drawRect(Rect.fromLTWH(0, size.y + 6, size.x * hpFraction, 6), Paint()..color = Colors.white);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.isGameplayActive) {
      return;
    }
    final currentPlayer = game.player;
    if (currentPlayer == null) {
      return;
    }
    final toPlayer = currentPlayer.center - center;
    if (toPlayer.length2 > 0) {
      position += toPlayer.normalized() * baseSpeed * game.enemySpeedMultiplier * dt;
    }
    position.x = position.x.clamp(0.0, math.max(0.0, game.size.x - size.x)).toDouble();
    position.y = position.y.clamp(game.playAreaTop, math.max(game.playAreaTop, game.size.y - size.y)).toDouble();
  }

  void takeDamage(int amount) {
    health -= amount;
    if (health <= 0) {
      game.awardBossKill(this);
      removeFromParent();
    }
  }
}

class BulletComponent extends PositionComponent with HasGameReference<SquareShooterGame> {
  BulletComponent({
    required super.position,
    required Vector2 direction,
    required this.damage,
    required this.speed,
    required double bulletSize,
    this.homingStrength = 0,
    this.remainingHits = 0,
    required this.tint,
  })  : direction = direction.normalized(),
        super(size: Vector2.all(bulletSize));

  Vector2 direction;
  final int damage;
  final double speed;
  final double homingStrength;
  int remainingHits;
  final Color tint;

  Rect get rect => Rect.fromLTWH(position.x, position.y, size.x, size.y);

  bool registerHit() {
    if (remainingHits > 0) {
      remainingHits -= 1;
      return true;
    }
    return false;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), Paint()..color = tint);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.isGameplayActive) {
      return;
    }
    if (homingStrength > 0) {
      final center = position + size / 2;
      final targetCenter = game.nearestThreatCenterTo(center);
      if (targetCenter != null) {
        final desired = (targetCenter - center).normalized();
        direction = (direction * (1 - homingStrength * dt) + desired * (homingStrength * dt)).normalized();
      }
    }
    position += direction * speed * dt;
    if (position.x < -size.x || position.y < -size.y || position.x > game.size.x + size.x || position.y > game.size.y + size.y) {
      removeFromParent();
    }
  }
}

class CoinComponent extends PositionComponent with HasGameReference<SquareShooterGame> {
  CoinComponent({required super.position, required this.value}) : super(size: Vector2.all(12));

  final int value;
  double life = 11;

  Rect get rect => Rect.fromLTWH(position.x, position.y, size.x, size.y);
  Vector2 get center => position + size / 2;

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = value >= 10 ? const Color(0xFFFFD700) : const Color(0xFFFFE066);
    canvas.drawOval(Rect.fromLTWH(0, 0, size.x, size.y), paint);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.gameOver || game.pausedForMenu || game.pausedForLevel) {
      return;
    }
    life -= dt;
    if (life <= 0) {
      removeFromParent();
      return;
    }
    final currentPlayer = game.player;
    if (currentPlayer == null) {
      return;
    }
    final toPlayer = currentPlayer.center - center;
    if (toPlayer.length2 > 0 && toPlayer.length < 130) {
      position += toPlayer.normalized() * 220 * dt;
    }
    position.y = position.y.clamp(game.playAreaTop, math.max(game.playAreaTop, game.size.y - size.y)).toDouble();
  }
}

class HudOverlay extends StatelessWidget {
  const HudOverlay({super.key, required this.game});

  static const id = 'hud';
  final SquareShooterGame game;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: game.uiTick,
      builder: (_, __, ___) {
        final currentPlayer = game.player;
        return SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 12,
                left: 12,
                right: 12,
                child: Card(
                  color: Colors.black.withValues(alpha: 0.58),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 16,
                          runSpacing: 8,
                          children: [
                            _stat('Coins', '${game.credits}'),
                            _stat('Round', '${game.currentRound}'),
                            _stat('Unit', '${game.checkpointCourseLesson.unitNumber}'),
                            _stat('Kills', '${game.kills}'),
                            _stat('Lives', _livesText(game.lives)),
                            _stat('Weapon', game.activeWeapon.title),
                            _stat('Threats', '${game.roundProgressCount}/${game.totalThreatsThisRound}'),
                            _stat(
                              'Dash',
                              currentPlayer == null
                                  ? '--'
                                  : currentPlayer.dashCooldownRemaining <= 0
                                      ? 'Ready'
                                      : currentPlayer.dashCooldownRemaining.toStringAsFixed(1),
                            ),
                            _stat('Bosses', '${game.defeatedBossCount}'),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: game.levelProgress.clamp(0.0, 1.0).toDouble(),
                            minHeight: 10,
                            backgroundColor: Colors.white12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                bottom: 16,
                child: _VirtualJoystick(onChanged: game.setTouchDirection),
              ),
              if (game.bannerText != null)
                Positioned(
                  top: 96,
                  left: 20,
                  right: 20,
                  child: Center(
                    child: Card(
                      color: Colors.black.withValues(alpha: 0.72),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Text(
                          game.bannerText!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                right: 20,
                bottom: 122,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FilledButton.tonal(
                      onPressed: game.isReady ? game.openWeaponSelect : null,
                      child: Text('Weapons\n${game.activeWeapon.title}', textAlign: TextAlign.center),
                    ),
                    const SizedBox(height: 10),
                    FilledButton.tonal(
                      onPressed: game.isReady ? game.openWeaponUpgrade : null,
                      child: const Text('Upgrade\nScreen', textAlign: TextAlign.center),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 16,
                bottom: 20,
                child: FilledButton.tonal(
                  onPressed: game.isGameplayActive ? game.triggerDash : null,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(92, 92),
                    shape: const CircleBorder(),
                  ),
                  child: const Text('DASH'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _livesText(int count) {
    if (count <= 0) {
      return '0';
    }
    return List<String>.filled(count, '❤').join(' ');
  }

  Widget _stat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class TitleOverlay extends StatelessWidget {
  const TitleOverlay({super.key, required this.game});

  static const id = 'title';
  final SquareShooterGame game;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Biology Game',
                    style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'This version is harder. Enemies arrive in dense survivor-style waves, bosses appear every few rounds, and you auto-fire constantly at the nearest threat.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Checkpoint: Round ${game.checkpointRound}, Unit ${game.checkpointCourseLesson.unitNumber} � ${game.checkpointCourseLesson.unitTitle}',
                    style: const TextStyle(fontSize: 15, color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  const Text('Rules', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  const Text('• Rounds are harder and denser, more like a survivor arena'),
                  const Text('• Most rounds give a stat shop with movement speed, attack speed, and reload speed'),
                  const Text('• Every third round gives a weapon shop with 3 random weapon offers and weapon upgrades'),
                  const Text('• Play Again resumes from your saved lesson checkpoint'),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      FilledButton(
                        onPressed: game.handleTitleStart,
                        child: const Text('Start Run'),
                      ),
                      OutlinedButton(
                        onPressed: game.startFreshCourse,
                        child: const Text('Start Fresh Course'),
                      ),
                      OutlinedButton(
                        onPressed: game.openTutorial,
                        child: const Text('Tutorial'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TutorialOverlay extends StatelessWidget {
  const TutorialOverlay({super.key, required this.game});

  static const id = 'tutorial';
  final SquareShooterGame game;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Card(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Tutorial',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          onPressed: game.closeTutorial,
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    _tutorialSection(
                      'Movement',
                      'Move with WASD, arrow keys, or the joystick. Dash with Space or the DASH button. Your weapon fires automatically at the nearest enemy.',
                    ),
                    _tutorialSection(
                      'Harder survivor waves',
                      'Each round throws bigger swarms at you. Clear the whole wave, then survive the boss round every third wave.',
                    ),
                    _tutorialSection(
                      'Shops',
                      'Most rounds end with a stat shop. In those rounds you can only buy movement speed, attack speed, and reload speed. Every third round is a weapon shop round.',
                    ),
                    _tutorialSection(
                      'Weapon shop rounds',
                      'Weapon shop rounds show exactly 3 random weapons to buy. If you already picked a weapon path, those rounds instead focus on upgrades for your current weapon.',
                    ),
                    _tutorialSection(
                      'Round breaks',
                      "After a round ends, you read a short lesson, take a three-question quiz, and then spend coins in that round's shop before the next wave starts.",
                    ),
                    _tutorialSection(
                      'Checkpoints',
                      'If you lose, Play Again resumes from your saved unit checkpoint instead of sending you back to the start.',
                    ),
                    const SizedBox(height: 18),
                    FilledButton(
                      onPressed: game.closeTutorial,
                      child: Text(game.startAfterTutorial ? 'Start Run' : 'Close Tutorial'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tutorialSection(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(body, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class WeaponSelectOverlay extends StatelessWidget {
  const WeaponSelectOverlay({super.key, required this.game});

  static const id = 'weapon_select';
  final SquareShooterGame game;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Weapons now appear in special round shops.', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text('Every third round shows 3 random weapon offers inside the end-of-round shop.'),
                  const SizedBox(height: 16),
                  FilledButton(onPressed: game.closeWeaponSelect, child: const Text('Close')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WeaponUpgradeOverlay extends StatelessWidget {
  const WeaponUpgradeOverlay({super.key, required this.game});

  static const id = 'weapon_upgrade';
  final SquareShooterGame game;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Weapon upgrades are now in the round-end shop.', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text('Special rounds let you improve weapon abilities and buy from 3 random weapon offers.'),
                  const SizedBox(height: 16),
                  FilledButton(onPressed: game.closeWeaponUpgrade, child: const Text('Close')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LevelOverlay extends StatelessWidget {
  const LevelOverlay({super.key, required this.game});

  static const id = 'level';
  final SquareShooterGame game;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: game.uiTick,
      builder: (_, __, ___) {
        final session = game.currentLessonSession;
        if (session == null) {
          return const SizedBox.shrink();
        }
        return Material(
          color: Colors.black54,
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 820, maxHeight: constraints.maxHeight * 0.92),
                    child: Card(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(22),
                        child: _buildContent(context, session),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, LevelLessonSession session) {
    switch (session.step) {
      case LessonOverlayStep.reading:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Round ${session.roundNumber} complete', style: const TextStyle(fontSize: 18, color: Colors.white70)),
            const SizedBox(height: 8),
            Text('Unit ${session.lesson.unitNumber}: ${session.lesson.unitTitle}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(session.lesson.title, style: const TextStyle(fontSize: 18, color: Colors.white70)),
            const SizedBox(height: 16),
            Text(session.lesson.prompt, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(16),
              ),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 17, height: 1.45, color: Colors.white),
                  children: buildGlossarySpans(context, session.lesson.readingText),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Tap the blue underlined words to see a beginner-friendly definition.',
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 14),
            Text(session.lesson.sourceCredit, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('Key terms in this unit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final term in session.lesson.keyTerms)
                  ActionChip(
                    label: Text(term),
                    onPressed: () {
                      final entry = glossaryForTerm(term);
                      if (entry != null) {
                        showGlossaryDefinition(context, entry);
                      }
                    },
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text('Sources: ${session.lesson.sourceTitle}', style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            SelectableText(session.lesson.sourceUrl, style: const TextStyle(color: Colors.lightBlueAccent)),
            const SizedBox(height: 22),
            FilledButton(onPressed: game.startLessonQuestions, child: const Text('Begin 3-question quiz')),
          ],
        );
      case LessonOverlayStep.questions:
        final index = session.questionIndex;
        final question = session.presentedQuestions[index];
        final selected = session.selectedAnswers[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Unit ${session.lesson.unitNumber} quiz', style: const TextStyle(fontSize: 18, color: Colors.white70)),
            const SizedBox(height: 8),
            Text('Question ${index + 1} of ${session.presentedQuestions.length}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text(question.prompt, style: const TextStyle(fontSize: 19)),
            const SizedBox(height: 18),
            ...List.generate(question.choices.length, (choiceIndex) {
              final isSelected = selected == choiceIndex;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    side: BorderSide(color: isSelected ? Colors.lightBlueAccent : Colors.white24, width: isSelected ? 2 : 1),
                    padding: const EdgeInsets.all(16),
                  ),
                  onPressed: () => game.selectLessonAnswer(choiceIndex),
                  child: Text(question.choices[choiceIndex]),
                ),
              );
            }),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: selected == null ? null : game.submitLessonAnswer,
              child: Text(index == session.presentedQuestions.length - 1 ? 'Finish quiz' : 'Next question'),
            ),
          ],
        );
      case LessonOverlayStep.results:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(session.resultTitle, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(session.resultSummary, style: const TextStyle(fontSize: 17)),
            const SizedBox(height: 20),
            Text(
              game.isWeaponShopRound(session.roundNumber)
                  ? 'Weapon shop before the next round'
                  : 'Stat shop before the next round',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text('Active weapon: ${game.activeWeapon.title} • Special level: ${game.activeWeaponState.specialLevel}'),
            const SizedBox(height: 14),
            if (!game.isWeaponShopRound(session.roundNumber)) ...[
              const Text('This is a stat round. You can only buy movement speed, attack speed, and reload speed.', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 12),
              ...game.upgrades.values.map((upgrade) {
                final base = game.upgradeCost(upgrade.id);
                final price = game.lessonUpgradeCost(upgrade.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    color: const Color(0xFF1A2238),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${upgrade.title}  Lv.${upgrade.level}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          Text(upgrade.description),
                          const SizedBox(height: 10),
                          Text('Base cost: $base'),
                          Text(price == base ? 'Current cost: $price' : 'Discounted cost: $price'),
                          const SizedBox(height: 10),
                          FilledButton(
                            onPressed: game.canAffordLessonUpgrade(upgrade.id) ? () => game.buyLessonUpgrade(upgrade.id) : null,
                            child: Text('Buy for $price'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ] else ...[
              const Text('This is a weapon round. You can buy from 3 random weapon offers and improve weapon specials.', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 12),
              if (!game.weaponPathLocked && game.currentWeaponOffers.isNotEmpty) ...[
                const Text('Random weapon offers', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                ...game.currentWeaponOffers.map((weapon) {
                  final state = game.weaponStates[weapon]!;
                  final canBuy = game.canAffordWeapon(weapon);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      color: const Color(0xFF1A2238),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(weapon.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            Text(weapon.description),
                            const SizedBox(height: 8),
                            Text(game.weaponSpecialSummary(weapon)),
                            const SizedBox(height: 8),
                            Text(state.unlocked ? 'Owned weapon' : 'Purchase cost: ${weapon.purchaseCost} coins'),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                FilledButton(
                                  onPressed: state.unlocked ? () => game.equipWeapon(weapon) : (canBuy ? () => game.buyWeapon(weapon) : null),
                                  child: Text(state.unlocked ? 'Equip' : 'Buy for ${weapon.purchaseCost}'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 6),
              ] else if (!game.weaponPathLocked) ...[
                const Text('No weapon offers remain this run.', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
              ],
              const Text('Weapon special upgrades', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              ...game.unlockedWeapons.map((weapon) {
                final cost = game.specialUpgradeCost(weapon);
                final state = game.weaponStates[weapon]!;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    color: const Color(0xFF1A2238),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text('${weapon.title}  Special Lv.${state.specialLevel}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                              ),
                              if (game.activeWeapon == weapon) const Chip(label: Text('Active')),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(game.weaponSpecialSummary(weapon)),
                          const SizedBox(height: 8),
                          Text('Upgrade cost: $cost coins'),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              FilledButton(
                                onPressed: game.canAffordWeaponUpgrade(weapon) ? () => game.buyWeaponSpecialUpgrade(weapon) : null,
                                child: Text('Upgrade for $cost'),
                              ),
                              OutlinedButton(
                                onPressed: game.activeWeapon == weapon ? null : () => game.equipWeapon(weapon),
                                child: const Text('Equip'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
            const SizedBox(height: 6),
            OutlinedButton(onPressed: game.skipLessonUpgrade, child: const Text('Start next round')),
          ],
        );
    }
  }
}

class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({super.key, required this.game});

  static const id = 'game_over';
  final SquareShooterGame game;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: game.uiTick,
      builder: (_, __, ___) {
        return Material(
          color: Colors.black54,
          child: Center(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Game Over', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 14),
                    Text('Round reached: ${game.currentRound}'),
                    Text('Time survived: ${game.survivalTime.toStringAsFixed(1)}s'),
                    Text('Kills: ${game.kills}'),
                    Text('Coins collected: ${game.totalCoinsCollected}'),
                    Text('Bosses defeated: ${game.defeatedBossCount}'),
                    Text('Final weapon: ${game.activeWeapon.title}'),
                    Text('Resume checkpoint: Round ${game.checkpointRound}, Unit ${game.checkpointCourseLesson.unitNumber} � ${game.checkpointCourseLesson.unitTitle}'),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        FilledButton(onPressed: game.restartGame, child: const Text('Play Again from Checkpoint')),
                        OutlinedButton(onPressed: game.returnToTitle, child: const Text('Title Screen')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _VirtualJoystick extends StatefulWidget {
  const _VirtualJoystick({required this.onChanged});

  final ValueChanged<Vector2> onChanged;

  @override
  State<_VirtualJoystick> createState() => _VirtualJoystickState();
}

class _VirtualJoystickState extends State<_VirtualJoystick> {
  static const double baseSize = 120;
  static const double knobSize = 48;
  Offset knobOffset = Offset.zero;

  void _updateOffset(Offset localPosition) {
    const radius = baseSize / 2;
    final center = const Offset(radius, radius);
    var delta = localPosition - center;
    final distance = delta.distance;
    final maxDistance = radius - knobSize / 2;
    if (distance > maxDistance && distance > 0) {
      delta = delta / distance * maxDistance;
    }
    setState(() {
      knobOffset = delta;
    });
    final normalized = Vector2(delta.dx / maxDistance, delta.dy / maxDistance);
    if (normalized.length2 > 1) {
      normalized.normalize();
    }
    widget.onChanged(normalized);
  }

  void _reset() {
    setState(() {
      knobOffset = Offset.zero;
    });
    widget.onChanged(Vector2.zero());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) => _updateOffset(details.localPosition),
      onPanUpdate: (details) => _updateOffset(details.localPosition),
      onPanEnd: (_) => _reset(),
      onPanCancel: _reset,
      child: SizedBox(
        width: baseSize,
        height: baseSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: baseSize,
              height: baseSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
                border: Border.all(color: Colors.white24, width: 2),
              ),
            ),
            Transform.translate(
              offset: knobOffset,
              child: Container(
                width: knobSize,
                height: knobSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.28),
                  border: Border.all(color: Colors.white54, width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/
