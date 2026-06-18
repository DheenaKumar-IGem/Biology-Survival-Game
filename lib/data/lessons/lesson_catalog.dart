import 'lesson_def.dart';

/// All lesson/quiz content shown after each round, building from general
/// immunology (rounds 1-3) into the PDAC-specific curriculum (rounds 4-9):
/// pancreas anatomy, risk factors, the KRAS mutation, staging, early
/// detection, and treatment.
class LessonCatalog {
  LessonCatalog._();

  static const lessonRound1 = LessonContent(
    id: 'lesson_round_1',
    title: 'Unit 1: Meet Your Immune System',
    readingText:
        "Your body is made of trillions of tiny cells, each doing a job to "
        "keep you alive. Your immune system is the body's defense team - it "
        "finds and destroys things that don't belong, like viruses and "
        "bacteria.\n\n"
        "Some immune cells respond fast to almost any invader; this is "
        "called the innate immune response, and it's your first line of "
        "defense. A slower, learned response makes antibodies - proteins that "
        "recognize one specific invader. Antibodies mostly tag or mark a "
        "target so other immune cells can come finish it off - they don't "
        "usually kill on contact. This is the antibody (adaptive) response. "
        "A third type of response, the cytotoxic response, uses cells that "
        "directly destroy infected or abnormal cells.\n\n"
        "In real biology these three responses overlap and work together - "
        "this game splits them into three separate kinds to make matching "
        "easier to learn.\n\n"
        "In this game, your weapons represent these three types of immune "
        "responses. Matching your weapon's response type to an enemy's type "
        "deals bonus damage - and using the wrong type deals much less, so "
        "some shielded threats barely take damage until you swap. For the "
        "pancreatic-cancer enemies later on, an enemy's color is just a game "
        "device to tell you which weapon to match - it isn't a claim about "
        "which real immune response would beat that exact cell. This is "
        "groundwork: once you know these basics, the later units use them to "
        "tell the pancreas and saliva story.",
    keyTerms: [
      'Immune system',
      'Innate immunity',
      'Antibody',
      'Cytotoxic response',
      'Cell',
      'Pathogen',
    ],
    questions: [
      LessonQuestion(
        question: "What is the immune system's main job?",
        options: [
          'To defend the body against harmful invaders',
          'To digest food',
          'To pump blood through the body',
          'To carry oxygen around the body',
        ],
        correctIndex: 0,
        explanation:
            'The immune system protects the body by finding and fighting harmful invaders like viruses and bacteria. Carrying oxygen is the job of red blood cells, not the immune defense.',
      ),
      LessonQuestion(
        question: 'Which immune response acts fast against almost any invader?',
        options: [
          'Innate immunity',
          'Antibody (adaptive) response',
          'Cytotoxic response',
          'Digestion',
        ],
        correctIndex: 0,
        explanation:
            'Innate immunity is the fast first response. It attacks many kinds of invaders before the body has learned a specific target.',
      ),
      LessonQuestion(
        question:
            "In this game, what happens when your weapon's category "
            "matches an enemy's category?",
        options: [
          'You deal extra (bonus) damage',
          'You deal less damage than a mismatch',
          'The enemy heals back to full health',
          'Nothing changes',
        ],
        correctIndex: 0,
        explanation:
            'Matching deals bonus damage; mismatched hits deal much less, so swap to the color that matches each threat.',
      ),
    ],
  );

  static const lessonRound2 = LessonContent(
    id: 'lesson_round_2',
    title: 'Unit 2: Know Your Enemy - Germs',
    readingText:
        "Not all germs behave the same way, and your immune system has to "
        "handle each kind differently. Viruses are tiny invaders that break "
        "into a cell and force it to make copies of the virus. In this game, "
        "when you destroy a virus it may split into smaller copies - that's "
        "not real virus replication, it's a game way to show how an infection "
        "can keep spreading before it's fully cleared.\n\n"
        "Bacteria are their own living cells, and some protect themselves "
        "with a biofilm - a slimy shield that has to be worn down before "
        "the bacteria underneath can be harmed. Fungi can spread using "
        "spores, tiny particles that can drift away and keep causing "
        "problems even after the main fungus is gone.\n\n"
        "Recognizing how a threat behaves - not just what it is - helps "
        "your immune system (and you, in this game) respond effectively. "
        "These first two units are groundwork: the general germ-fighting "
        "ideas here set up the pancreas and saliva story in the later units.",
    keyTerms: [
      'Virus',
      'Bacteria',
      'Fungus',
      'Viral Replication',
      'Biofilm',
      'Spore',
    ],
    questions: [
      LessonQuestion(
        question: 'What is a virus?',
        options: [
          'A tiny invader that breaks into cells and makes copies of itself',
          'A type of white blood cell',
          'A vitamin found in food',
          'A muscle in the digestive system',
        ],
        correctIndex: 0,
        explanation:
            'Viruses enter cells and use those cells to copy themselves, which is why viral infections can spread quickly.',
      ),
      LessonQuestion(
        question: 'What helps protect some bacteria from the immune system?',
        options: [
          'A biofilm - a protective shield around the bacteria',
          'A hard outer bone',
          'Moving faster than any immune cell',
          'Turning into a virus to hide',
        ],
        correctIndex: 0,
        explanation:
            'A biofilm is a protective slimy layer some bacteria build. In the game it acts like a shield that must be worn down first. Bacteria have no bones and do not turn into viruses.',
      ),
      LessonQuestion(
        question: 'After a fungus is destroyed, what can its spores still do?',
        options: [
          'Drift away and continue causing harm for a while',
          'Heal nearby germs back to full health',
          'Make the immune system stronger',
          'Nothing - they vanish instantly',
        ],
        correctIndex: 0,
        explanation:
            'Spores can linger after the fungus is gone, matching the damage clouds left behind in the arena.',
      ),
    ],
  );

  static const lessonRound3 = LessonContent(
    id: 'lesson_round_3',
    title: 'Unit 3: The Pancreas and Pancreatic Cancer',
    readingText:
        "The pancreas is a long, flat organ tucked behind your stomach. It "
        "has two main jobs: it makes enzymes that help digest food, and it "
        "produces insulin, a hormone that controls blood sugar. Both jobs "
        "depend on healthy cells lining tiny tubes called ducts.\n\n"
        "Pancreatic ductal adenocarcinoma, or PDAC, is the most common type "
        "of pancreatic cancer. It begins in the cells that line these "
        "ducts. Long-term inflammation of the pancreas, called chronic "
        "pancreatitis, can damage duct cells over time and is one factor "
        "linked to a higher risk of PDAC.\n\n"
        "The boss you just faced - the PanIN Lesion - represents an early "
        "pre-cancerous change in the duct lining. PanIN is short for "
        "pancreatic intraepithelial neoplasia - just a name doctors use for a "
        "tiny abnormal patch that is not cancer yet, so don't worry about "
        "memorizing the long version. Finding changes this early gives doctors "
        "and researchers more time to understand what is happening.",
    keyTerms: [
      'Pancreas',
      'Duct cells',
      'Enzymes',
      'Insulin',
      'Pancreatitis',
      'Adenocarcinoma',
    ],
    questions: [
      LessonQuestion(
        question: 'What are the two main jobs of the pancreas?',
        options: [
          'Making digestive enzymes and producing insulin',
          'Pumping blood and filtering air',
          'Storing memories and producing sound',
          'Growing hair and nails',
        ],
        correctIndex: 0,
        explanation:
            'The pancreas helps digest food with enzymes and controls blood sugar by making insulin.',
      ),
      LessonQuestion(
        question: 'Where does pancreatic ductal adenocarcinoma (PDAC) begin?',
        options: [
          'In the cells lining the pancreatic ducts',
          'In the insulin-producing islet cells',
          'In the lining of the lungs',
          'In the muscles of the leg',
        ],
        correctIndex: 0,
        explanation:
            'PDAC starts in duct-lining cells, which is why the full name includes ductal adenocarcinoma. Islet cells (which make insulin) are also in the pancreas, but they are not where PDAC begins.',
      ),
      LessonQuestion(
        question: 'Which chronic condition is linked to a higher risk of PDAC?',
        options: [
          'Long-term inflammation of the pancreas (pancreatitis)',
          'A broken bone that has healed',
          'Mild seasonal allergies',
          'Occasional muscle soreness',
        ],
        correctIndex: 0,
        explanation:
            'Chronic pancreatitis means long-term pancreas inflammation, and that ongoing damage is linked with higher PDAC risk.',
      ),
    ],
  );

  static const lessonRound4 = LessonContent(
    id: 'lesson_round_4',
    title: 'Unit 4: Risk Factors for Pancreatic Cancer',
    readingText:
        "A risk factor is anything that makes a disease more likely to "
        "happen - it doesn't guarantee someone will get sick, but it raises "
        "the odds. It's important to know that most pancreatic cancer is not "
        "caused by anything a person did, and getting it is no one's fault. "
        "In fact, the single biggest risk factor is simply getting older, "
        "which nobody can control - PDAC is much more common in older "
        "adults.\n\n"
        "Some other factors have been linked to higher risk, including "
        "smoking, heavy alcohol use, long-term inflammation of the pancreas "
        "(chronic pancreatitis), being significantly overweight, and having "
        "type 2 diabetes for a long time. Family history matters too: if a "
        "close relative has had pancreatic cancer, or if certain genes run "
        "in the family, a person's own risk can be a bit higher.\n\n"
        "A few of these are things people can influence. Not smoking, "
        "limiting alcohol, eating a balanced diet, staying active, and "
        "keeping a healthy weight can all help lower overall risk for many "
        "diseases - but none of this is a guarantee, and many people who "
        "never do anything 'wrong' still get sick.",
    keyTerms: [
      'Risk factor',
      'Smoking',
      'Obesity',
      'Family history',
      'Type 2 diabetes',
    ],
    questions: [
      LessonQuestion(
        question:
            'Which of these is a well-known risk factor for pancreatic '
            'cancer?',
        options: [
          'Smoking',
          'Eating spicy food',
          'Catching a cold from someone',
          'Sitting too close to the TV',
        ],
        correctIndex: 0,
        explanation:
            'Smoking is one of the best-known risk factors for pancreatic cancer, though it does not guarantee someone will get sick. Spicy food, catching colds, and sitting near a screen are not causes - and remember, most pancreatic cancer is not anyone\'s fault.',
      ),
      LessonQuestion(
        question:
            'Having a close relative with pancreatic cancer can affect a '
            "person's own risk by:",
        options: [
          'Increasing it',
          'Eliminating it completely',
          'Having no effect at all',
          'Making it impossible to get any cancer',
        ],
        correctIndex: 0,
        explanation:
            'Family history can point to shared genes or inherited risk, so a close relative can raise a person\'s own risk.',
      ),
      LessonQuestion(
        question:
            'Which lifestyle change can help lower a person\'s overall '
            'risk?',
        options: [
          'Maintaining a healthy weight and not smoking',
          'Avoiding all forms of exercise',
          'Skipping meals every day',
          'Avoiding regular checkups',
        ],
        correctIndex: 0,
        explanation:
            'Not smoking and maintaining a healthy weight are choices that can lower overall risk for several diseases, including pancreatic cancer.',
      ),
    ],
  );

  static const lessonRound5 = LessonContent(
    id: 'lesson_round_5',
    title: 'Unit 5: The KRAS Gene Mutation',
    readingText:
        "Genes are like instruction manuals inside every cell, telling it "
        "how to grow, divide, and behave. One important gene is called "
        "KRAS. In a healthy cell, KRAS acts like an on/off switch that "
        "helps control when the cell should grow and divide.\n\n"
        "In most pancreatic ductal adenocarcinomas - around 90% - the KRAS "
        "gene is mutated. A mutation is a change in the gene's "
        "instructions. A mutated KRAS gene can get stuck in the 'on' "
        "position, constantly telling the cell to keep growing and "
        "dividing even when it shouldn't. Importantly, KRAS is an early "
        "driver: the cancer carries this change from the start - it is not "
        "something the immune system creates by attacking too much. And "
        "because most PDAC carries a KRAS driver alteration, it is one of "
        "the molecular clues researchers hope to understand and spot early in body fluids "
        "like saliva.\n\n"
        "This is what the 'mutation' mechanic in this game stands for: "
        "because the enemy already carries driver changes like a mutated "
        "KRAS, leaning on just one type of immune response lets it slip past "
        "that single attack. Mixing your responses gives the cancer fewer "
        "ways to escape - a varied defense works better.",
    keyTerms: ['Gene', 'Mutation', 'KRAS', 'Oncogene', 'Cell growth signal'],
    questions: [
      LessonQuestion(
        question: 'What does a gene normally do?',
        options: [
          'Carries instructions that control how a cell behaves',
          'Supplies the cell with its energy',
          'Stores digested food',
          'Produces sound waves',
        ],
        correctIndex: 0,
        explanation:
            'Genes carry instructions that help cells know when to grow, divide, repair, or stop. Making energy is the job of other parts of the cell (the mitochondria), not the genes themselves.',
      ),
      LessonQuestion(
        question:
            'What happens when the KRAS gene is mutated in pancreatic '
            'cancer?',
        options: [
          "It gets stuck in the 'on' position, telling the cell to keep "
              'growing',
          'It permanently shuts the cell down',
          'It turns the cell into a muscle cell',
          'It has no effect on the cell at all',
        ],
        correctIndex: 0,
        explanation:
            "A mutated KRAS gene keeps the cell's growth switch stuck in the 'on' position, so it keeps sending grow-and-divide signals.",
      ),
      LessonQuestion(
        question:
            'About what percentage of pancreatic ductal adenocarcinomas '
            'have a KRAS mutation?',
        options: ['About 90%', 'About 5%', 'About 25%', 'About 50%'],
        correctIndex: 0,
        explanation:
            'KRAS mutations are found in most PDAC cases, often described as roughly 90%.',
      ),
    ],
  );

  static const lessonRound6 = LessonContent(
    id: 'lesson_round_6',
    title: 'Unit 6: From Mutated Cell to Tumor',
    readingText:
        "A single mutated cell doesn't become a tumor overnight. Pancreatic "
        "cancer usually develops gradually, through a series of changes "
        "that build up over many years. Along the way, cells can become "
        "'dysplastic' - meaning they look and behave abnormally, but aren't "
        "cancerous yet.\n\n"
        "If these abnormal changes continue, the cells can eventually form "
        "a tumor. When a tumor is still confined to the pancreas itself, "
        "doctors describe it as 'localized.' Catching changes at this "
        "stage gives doctors the most options for treatment - and this early, "
        "localized window is exactly what a saliva-based early-detection test "
        "would aim to catch.\n\n"
        "The boss you just faced - the Localized Tumor - represents this "
        "growing tumor mass. Its support cells mirror the dense tissue "
        "around many PDAC tumors that can protect cancer cells.",
    keyTerms: [
      'Dysplasia',
      'PanIN',
      'Localized tumor',
      'Tumor growth',
      'Progression',
    ],
    questions: [
      LessonQuestion(
        question: 'What does the term "dysplasia" mean?',
        options: [
          "Cells that look and behave abnormally but aren't cancer yet",
          'A type of healthy muscle cell',
          'A medicine used to treat infections',
          'A part of the digestive tract',
        ],
        correctIndex: 0,
        explanation:
            'Dysplastic cells are abnormal, but they are not fully cancer yet. They can be part of a slow progression.',
      ),
      LessonQuestion(
        question:
            "A tumor that hasn't spread beyond the pancreas is described "
            'as:',
        options: ['Localized', 'Metastatic', 'Regional', 'Contagious'],
        correctIndex: 0,
        explanation:
            'Localized means the tumor is still in its original area instead of spreading to distant organs. "Regional" would mean it had already reached nearby tissue or lymph nodes, so it is not the right word here.',
      ),
      LessonQuestion(
        question: 'How does pancreatic cancer typically develop?',
        options: [
          'Gradually, through a series of changes over many years',
          'Instantly, within a single day',
          'Only as a result of a broken bone',
          'It does not develop from normal cells at all',
        ],
        correctIndex: 0,
        explanation:
            'Pancreatic cancer usually builds through many changes over time, which is why early warning signs matter.',
      ),
    ],
  );

  static const lessonRound7 = LessonContent(
    id: 'lesson_round_7',
    title: 'Unit 7: Cancer Staging',
    readingText:
        "Once cancer is found, doctors use 'staging' to describe how far it "
        "has spread. Staging usually ranges from very early stages, where a "
        "tumor is small and localized, to later stages where it has grown "
        "into nearby tissue or spread further.\n\n"
        "Doctors often sort spread into three simple groups. 'Localized' "
        "means the cancer is still only where it started. 'Regional' means "
        "it has reached nearby tissue or lymph nodes. 'Distant' means it has "
        "traveled to far-off organs. Doctors also use a separate numbered "
        "system (Stage I to IV), where this most advanced, distant spread is "
        "Stage IV.\n\n"
        "When cancer cells travel through the body and form new growths in "
        "distant organs - like the liver - this is called metastasis. "
        "Metastatic cancer is generally harder to treat than cancer that "
        "is still localized.\n\n"
        "Staging isn't just a label - it helps doctors choose the most "
        "appropriate treatment plan and helps predict what to expect. A "
        "smaller, earlier stage usually means more options, which is why "
        "catching PDAC early - the goal of the saliva test in the next unit - "
        "matters so much.",
    keyTerms: ['Staging', 'Metastasis', 'Localized', 'Regional', 'Stage IV'],
    questions: [
      LessonQuestion(
        question: 'What does cancer "staging" describe?',
        options: [
          'How far the cancer has spread in the body',
          'How long ago the tumor first formed',
          'How fast the cancer cells can move',
          'How painful the tumor feels to the patient',
        ],
        correctIndex: 0,
        explanation:
            'Staging tells doctors whether cancer is local, nearby (regional), or distant, which changes treatment choices. It is about how far the cancer has spread, not its age, speed, or how it feels.',
      ),
      LessonQuestion(
        question:
            'When cancer spreads to a distant organ like the liver, this '
            'is called:',
        options: ['Metastasis', 'Regional spread', 'Inflammation', 'Mutation'],
        correctIndex: 0,
        explanation:
            'Metastasis means cancer cells have traveled and formed new growths far away from where the cancer began. "Regional spread" only reaches nearby tissue or lymph nodes, so a distant organ like the liver counts as metastasis.',
      ),
      LessonQuestion(
        question: 'Why does staging matter for treatment?',
        options: [
          'It helps doctors choose the most effective treatment plan',
          'It decides how many days the patient stays in hospital',
          'It has no effect on treatment decisions',
          'It only matters after treatment is finished',
        ],
        correctIndex: 0,
        explanation:
            'Treatment plans depend heavily on stage, because a small local tumor is handled differently from cancer that has spread.',
      ),
    ],
  );

  static const lessonRound8 = LessonContent(
    id: 'lesson_round_8',
    title: 'Unit 8: Early Detection and Symptoms',
    readingText:
        "Saliva tests for pancreatic cancer are an exciting research idea, "
        "but they still need careful validation before they can be used "
        "broadly. A useful screening test must find true cancers without too "
        "many false positives or false negatives, and there is not yet a "
        "validated general saliva screening test you can go get.\n\n"
        "Pancreatic cancer is often found at a later stage because its "
        "early symptoms can be vague and easy to mistake for other "
        "problems - things like back or abdominal discomfort, unexplained "
        "weight loss, or feeling unusually tired.\n\n"
        "One symptom that can stand out is jaundice - a yellowing of the "
        "skin and eyes. This can happen when a tumor presses on or blocks "
        "the bile duct, a small tube that normally carries bile (a fluid "
        "that helps digest fat).\n\n"
        "Because early symptoms are easy to miss, people with a strong "
        "family history of pancreatic cancer or certain inherited genetic "
        "conditions may be offered regular monitoring. Researchers are also "
        "studying biomarkers - measurable biological clues - in samples like "
        "blood, pancreatic fluid, and saliva.\n\n"
        "How could a pancreas problem ever show up in your spit? As tumor "
        "cells grow, they shed bits of protein and DNA, along with tiny "
        "bubbles called vesicles, into the fluids around them. These pieces "
        "can drift into the bloodstream and circulate through the body, and a "
        "small amount can end up in saliva. A test sensitive enough to spot "
        "those faint clues might one day flag pancreatic cancer early - though "
        "this is still a research idea, not a test you can go get yet. The "
        "hope is a simple, noninvasive test, but researchers still have to "
        "prove sensitivity (catching real cancers) and specificity (not "
        "falsely alarming healthy people), plus real-world usefulness.",
    keyTerms: [
      'Jaundice',
      'Symptom',
      'Screening',
      'Early detection',
      'Bile duct',
      'Biomarker',
      'Saliva test',
    ],
    questions: [
      LessonQuestion(
        question: 'Why is pancreatic cancer often found at a later stage?',
        options: [
          'Its early symptoms are vague and easy to overlook',
          'It has no symptoms at any stage, ever',
          'It only affects people who feel perfectly healthy',
          'Doctors are not allowed to test for it',
        ],
        correctIndex: 0,
        explanation:
            'Early PDAC symptoms can be subtle, so people may not notice them or may mistake them for common problems.',
      ),
      LessonQuestion(
        question:
            'Yellowing of the skin and eyes, called jaundice, can happen '
            'when:',
        options: [
          'A tumor blocks the bile duct',
          'A person gets a good night of sleep',
          'A person exercises too much',
          'A person drinks too much water',
        ],
        correctIndex: 0,
        explanation:
            'A blocked bile duct can cause bilirubin to build up, which can make the skin and eyes look yellow.',
      ),
      LessonQuestion(
        question:
            'Who might be offered regular screening for pancreatic '
            'cancer?',
        options: [
          'People with a strong family history or certain genetic '
              'conditions',
          'Everyone, starting at birth',
          'Every adult, as a routine yearly checkup',
          'No one - screening does not exist',
        ],
        correctIndex: 0,
        explanation:
            'People with strong family history or inherited risk may be monitored more closely because their risk is higher. There is no validated routine pancreatic-cancer screening for the general adult population yet.',
      ),
    ],
  );

  static const lessonRound9 = LessonContent(
    id: 'lesson_round_9',
    title: 'Unit 9: Treatment and the Power of a Combined Defense',
    readingText:
        "Treating pancreatic cancer often depends on its stage. If a tumor "
        "is found early and is still localized, surgery to remove part of "
        "the pancreas may be possible. For tumors that have grown or "
        "spread, doctors often use chemotherapy - medicines that target "
        "rapidly dividing cancer cells throughout the body - sometimes "
        "alongside radiation.\n\n"
        "Researchers are also developing immunotherapy, which aims to help "
        "a person's own immune system recognize and attack cancer cells - "
        "a similar idea to the weapons you've used in this game. Pancreatic "
        "cancer has been especially hard for immunotherapy so far, because it "
        "is good at hiding from the immune system, and scientists are still "
        "working hard to make it work better for PDAC. They also test "
        "biomarker panels, because one signal by itself can be noisy or "
        "misleading.\n\n"
        "Doctors often combine multiple treatments, because relying on "
        "just one approach gives the cancer more chances to resist it - "
        "just like relying on only one immune response in this game let "
        "enemies adapt. A combined, varied defense gives the best chance "
        "of success, both in this game and in real treatment.",
    keyTerms: [
      'Surgery',
      'Chemotherapy',
      'Radiation',
      'Immunotherapy',
      'Clinical trial',
    ],
    questions: [
      LessonQuestion(
        question:
            'Which treatment might be an option if a pancreatic tumor is '
            'caught early and is still localized?',
        options: [
          'Surgery to remove the tumor',
          'No treatment is ever possible',
          'Only changing diet',
          'Only rest and sleep',
        ],
        correctIndex: 0,
        explanation:
            'If cancer is found while still localized, surgery may be possible because doctors can try to remove the tumor.',
      ),
      LessonQuestion(
        question: 'Chemotherapy works by:',
        options: [
          'Using drugs that target rapidly dividing cancer cells '
              'throughout the body',
          'Freezing the whole body until the cancer stops',
          'Only affecting cells in the skin',
          'Replacing the immune system entirely',
        ],
        correctIndex: 0,
        explanation:
            'Chemotherapy uses medicines that attack rapidly dividing cells, which includes many cancer cells. It is not a freezing treatment and it works far beyond just the skin.',
      ),
      LessonQuestion(
        question: 'Why do doctors often combine multiple types of treatment?',
        options: [
          'Combining approaches can be more effective than relying on '
              'just one',
          'Combining treatments is required by law in all cases',
          'It guarantees there are no side effects',
          'It has no real benefit over using a single treatment',
        ],
        correctIndex: 0,
        explanation:
            'Combining treatments can attack cancer in different ways, making it harder for one resistant strategy to win.',
      ),
      LessonQuestion(
        question:
            'A tumor already contains a few cells that can shrug off one '
            'kind of attack. Why does varying the attack work better than '
            'hammering with just one?',
        options: [
          'The cells that survive one attack can still be hit by a '
              'different one, so fewer can escape',
          'Using one attack many times slowly teaches every cell to '
              'become harmless',
          'Switching attacks makes the tumor shrink faster purely '
              'because it is confusing to look at',
          'A single attack always removes every cell, so variety is '
              'just for show',
        ],
        correctIndex: 0,
        explanation:
            'Because the tumor already carries cells that resist one attack, leaning on that single response lets those cells survive and take over. Varying the attack hits them in another way, so fewer cells can escape - the same reason mixing your immune responses beats spamming one in this game.',
      ),
    ],
  );

  /// All lessons, keyed by id.
  static const Map<String, LessonContent> all = {
    'lesson_round_1': lessonRound1,
    'lesson_round_2': lessonRound2,
    'lesson_round_3': lessonRound3,
    'lesson_round_4': lessonRound4,
    'lesson_round_5': lessonRound5,
    'lesson_round_6': lessonRound6,
    'lesson_round_7': lessonRound7,
    'lesson_round_8': lessonRound8,
    'lesson_round_9': lessonRound9,
  };
}
