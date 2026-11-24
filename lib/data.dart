/// Quiz data for the Fermah Quiz Hub.
/// All facts come from the verified HTML version. No token or airdrop is
/// promised anywhere, because no Fermah token has been confirmed.
library;

class QuizQuestion {
  const QuizQuestion({
    required this.question,
    required this.options,
    required this.answer,
    required this.explainer,
  });

  final String question;
  final List<String> options;
  final int answer;
  final String explainer;
}

class Quiz {
  const Quiz({
    required this.id,
    required this.title,
    required this.tag,
    required this.desc,
    required this.questions,
  });

  final String id;
  final String title;
  final String tag;
  final String desc;
  final List<QuizQuestion> questions;
}

String rankTitle(int score) {
  if (score >= 3000) return 'Fermafia OG';
  if (score >= 2200) return 'Moon Math Master';
  if (score >= 1500) return 'Kernel Keeper';
  if (score >= 1000) return 'Matchmaker';
  if (score >= 600) return 'Prover';
  if (score >= 250) return 'Proof Cadet';
  return 'Seeker';
}

const List<Quiz> quizzes = [
  Quiz(
    id: 'basics',
    title: 'Fermah Basics',
    tag: 'Start here',
    desc: 'What Fermah is, who builds it, and where to find it.',
    questions: [
      QuizQuestion(
        question: 'What is Fermah, in one line?',
        options: [
          'The universal proof generation layer',
          'A centralised exchange for ZK tokens',
          'A wallet for storing proofs',
          'A social network for cryptographers',
        ],
        answer: 0,
        explainer:
            'Fermah is the universal proof generation layer, a marketplace for zero knowledge proof generation.',
      ),
      QuizQuestion(
        question: "What does the supply side of Fermah's marketplace provide?",
        options: [
          'GPUs and FPGAs that generate proofs',
          'Loans to ZK startups',
          'Validators for proof of stake',
          'Storage for NFT art',
        ],
        answer: 0,
        explainer:
            'GPU and FPGA operators supply the compute that generates proofs.',
      ),
      QuizQuestion(
        question: 'Who sits on the demand side of the Fermah marketplace?',
        options: [
          'Projects and networks that need ZK proofs',
          'Only the Fermah team',
          'GPU manufacturers',
          'Central banks',
        ],
        answer: 0,
        explainer:
            'Rollups, bridges, ZKML projects and more buy proof generation from the marketplace.',
      ),
      QuizQuestion(
        question: 'Fermah wants proof generation to be cheap, fast and what?',
        options: ['Reliable', 'Secret', 'Free forever', 'Centralised'],
        answer: 0,
        explainer:
            'Cheap, fast and reliable is how Fermah describes its proof generation.',
      ),
      QuizQuestion(
        question: "What is Fermah's tagline?",
        options: [
          'Bringing moon math to the masses',
          'Proofs for everyone, everywhere',
          'The internet of money',
          'Zero knowledge, zero limits',
        ],
        answer: 0,
        explainer: 'Fermah says it is bringing moon math to the masses.',
      ),
      QuizQuestion(
        question: 'Where is Fermah headquartered?',
        options: ['New York', 'London', 'Singapore', 'Dubai'],
        answer: 0,
        explainer: 'Fermah is headquartered in New York City, USA.',
      ),
      QuizQuestion(
        question: "What is Fermah's official website?",
        options: ['fermah.xyz', 'fermah.com', 'fermah.io', 'fermah.org'],
        answer: 0,
        explainer: 'The official site is fermah.xyz.',
      ),
      QuizQuestion(
        question: "What is Fermah's handle on X?",
        options: ['@fermah_xyz', '@fermah', '@fermahzk', '@fermah_labs'],
        answer: 0,
        explainer: 'Fermah posts on X as @fermah_xyz.',
      ),
    ],
  ),
  Quiz(
    id: 'zk',
    title: 'ZK Zero to Hero',
    tag: 'Zero knowledge',
    desc: 'The basics of zero knowledge proofs, in plain words.',
    questions: [
      QuizQuestion(
        question: 'What does ZK stand for?',
        options: ['Zero-knowledge', 'Zero-key', 'Zeta-kernel', 'Zone-keeper'],
        answer: 0,
        explainer: 'ZK stands for zero-knowledge.',
      ),
      QuizQuestion(
        question: 'What does a zero-knowledge proof let you do?',
        options: [
          'Prove a statement is true without revealing the data behind it',
          'Delete data from a blockchain forever',
          'Mine new coins without hardware',
          'Send messages that nobody can read',
        ],
        answer: 0,
        explainer:
            'A ZK proof proves a claim is true while keeping the underlying data private.',
      ),
      QuizQuestion(
        question: "What is 'moon math'?",
        options: [
          'A playful name for the advanced cryptography behind ZK proofs',
          'A way to calculate moon phases onchain',
          'A token with lunar branding',
          'A formula for gas fees',
        ],
        answer: 0,
        explainer:
            'Moon math is the community nickname for the heavy cryptography that makes ZK proofs work.',
      ),
      QuizQuestion(
        question: 'Which of these is a real use case for ZK proofs?',
        options: [
          'ZK rollups that scale blockchains',
          'Printing physical banknotes',
          'Replacing all databases',
          'Making phones charge faster',
        ],
        answer: 0,
        explainer:
            'ZK rollups use proofs to scale blockchains while keeping them secure.',
      ),
      QuizQuestion(
        question: 'Why do ZK proofs help blockchains scale?',
        options: [
          'They let a chain verify work without redoing all of it',
          'They make blocks bigger by default',
          'They remove the need for nodes',
          'They compress every transaction to zero bytes',
        ],
        answer: 0,
        explainer:
            'A short proof can confirm a lot of work, so chains verify faster.',
      ),
      QuizQuestion(
        question: 'What is a prover?',
        options: [
          'The machine or party that generates a ZK proof',
          'A lawyer who checks smart contracts',
          'A token holder who votes',
          'A miner who finds new blocks',
        ],
        answer: 0,
        explainer: 'Provers do the compute work and generate the proof.',
      ),
      QuizQuestion(
        question: 'What does it mean to verify a proof?',
        options: [
          'Check the proof is valid without redoing the work',
          'Rewrite the proof from scratch',
          'Ask the prover to reveal the data',
          'Store the proof on every node',
        ],
        answer: 0,
        explainer:
            'Verification checks validity quickly, without repeating the computation.',
      ),
      QuizQuestion(
        question: 'What happens to private data inside a ZK proof?',
        options: [
          'It stays private while the claim is proven',
          'It is published onchain',
          'It is deleted after proving',
          'It is shared with the Matchmaker',
        ],
        answer: 0,
        explainer:
            'That is the point of zero knowledge: prove the claim, hide the data.',
      ),
    ],
  ),
  Quiz(
    id: 'systems',
    title: 'Proof Systems Arena',
    tag: 'Deep dive',
    desc: 'zkVMs, zkEVMs, Groth16, Seekers, Operators and the Matchmaker.',
    questions: [
      QuizQuestion(
        question: 'Which proof systems does Fermah support?',
        options: [
          'All of them, including zkVMs, zkEVMs and Groth16',
          'Only Groth16',
          'Only zkEVMs',
          'Only its own private system',
        ],
        answer: 0,
        explainer: 'Fermah is neutral and supports all proof systems.',
      ),
      QuizQuestion(
        question: 'What is Groth16?',
        options: [
          'A widely used ZK proof system',
          'A type of GPU',
          'A Fermah token',
          'A Discord role',
        ],
        answer: 0,
        explainer: 'Groth16 is one of the best known ZK proof systems.',
      ),
      QuizQuestion(
        question: 'What is a zkVM?',
        options: [
          'A virtual machine that proves its own execution with ZK proofs',
          'A video meeting app for ZK teams',
          'A virtual mining rig',
          'A version manager for ZK code',
        ],
        answer: 0,
        explainer:
            'A zkVM runs programs and produces a ZK proof that the run was correct.',
      ),
      QuizQuestion(
        question: 'What is a zkEVM?',
        options: [
          'An EVM compatible environment that generates ZK proofs',
          'An Ethereum wallet with ZK login',
          'A new EVM programming language',
          'An exchange for ZK tokens',
        ],
        answer: 0,
        explainer:
            'A zkEVM brings ZK proving to Ethereum style smart contracts.',
      ),
      QuizQuestion(
        question: 'What does the Fermah Matchmaker do?',
        options: [
          'Routes each ZK workload to the right compute',
          'Pairs community members for chats',
          'Matches buyers and sellers of tokens',
          'Sets the price of every proof',
        ],
        answer: 0,
        explainer:
            'The Matchmaker aligns demand with the right supply of compute.',
      ),
      QuizQuestion(
        question: 'Who are the Operators in the Fermah network?',
        options: [
          'People who run the GPUs and FPGAs that generate proofs',
          "Fermah's customer support team",
          'Discord moderators',
          'Token holders who vote on proposals',
        ],
        answer: 0,
        explainer:
            'Operators run the hardware on the supply side of the marketplace.',
      ),
      QuizQuestion(
        question: 'Who is a Seeker?',
        options: [
          'A project that needs a ZK proof generated',
          'A person looking for a job at Fermah',
          'A bot that scans for airdrops',
          'A validator on the testnet',
        ],
        answer: 0,
        explainer: 'Seekers bring the demand: they need proofs generated.',
      ),
      QuizQuestion(
        question: "Which statement about Fermah's proof support is true?",
        options: [
          'It is credibly neutral and supports every proof system',
          'It only works with one proof system at a time',
          'It charges more for Groth16 than for others',
          'It stopped supporting zkEVMs in 2025',
        ],
        answer: 0,
        explainer:
            'Fermah is built to support all proof systems, not to pick winners.',
      ),
    ],
  ),
  Quiz(
    id: 'kernel',
    title: 'Kernel and ULTRAMINT',
    tag: 'The engine',
    desc: 'Kernel, onchain markets, ULTRAMINT on Base, and the big numbers.',
    questions: [
      QuizQuestion(
        question: 'What is Kernel?',
        options: [
          'The engine everything Fermah runs is built on',
          'A new ZK proof system',
          'A Fermah community event',
          'A wallet for ULTRAMINT',
        ],
        answer: 0,
        explainer: 'Kernel is the engine under everything Fermah runs.',
      ),
      QuizQuestion(
        question: "What is Kernel's motto?",
        options: [
          'Write the rule. It runs.',
          'Proofs first, questions later.',
          'Mint fast, settle faster.',
          'Trust the market.',
        ],
        answer: 0,
        explainer: 'You write the rule, Kernel runs it.',
      ),
      QuizQuestion(
        question: 'What does Kernel turn into an onchain market?',
        options: [
          'Anything that can be measured',
          'Only sports results',
          'Only crypto prices',
          'Only election outcomes',
        ],
        answer: 0,
        explainer:
            'If it can be measured, Kernel turns it into an onchain market.',
      ),
      QuizQuestion(
        question: 'When are the rules of a Kernel market locked?',
        options: [
          'Before the first trade',
          'After the market closes',
          'When a dispute is raised',
          'Once a week',
        ],
        answer: 0,
        explainer:
            'The rules are locked before the first trade, so nobody can move the goalposts.',
      ),
      QuizQuestion(
        question: 'What is ULTRAMINT?',
        options: [
          'A live app to mint and trade markets, built on Fermah Kernel',
          'A Fermah NFT collection',
          'A testnet faucet',
          'A Discord bot',
        ],
        answer: 0,
        explainer:
            'ULTRAMINT is the first app built on Fermah Protocol: mint the market, earn the cut.',
      ),
      QuizQuestion(
        question: 'Which chain is ULTRAMINT live on?',
        options: ['Base', 'Ethereum mainnet', 'Solana', 'Stellar'],
        answer: 0,
        explainer: 'ULTRAMINT is live on Base.',
      ),
      QuizQuestion(
        question:
            'How many markets settled in 8 weeks, according to fermah.xyz?',
        options: ['285K', '28.5K', '2.85M', '850'],
        answer: 0,
        explainer: 'Fermah reports 285K markets settled in 8 weeks.',
      ),
      QuizQuestion(
        question:
            'How many proofs has Fermah generated, according to fermah.xyz?',
        options: ['4.2M', '420K', '42M', '4,200'],
        answer: 0,
        explainer: 'Fermah reports 4.2M proofs generated.',
      ),
    ],
  ),
  Quiz(
    id: 'blitz',
    title: 'True or False Blitz',
    tag: 'Speed round',
    desc: 'Judge the statement. True, or one of the false claims?',
    questions: [
      QuizQuestion(
        question: 'Fermah raised \$5.2M in a seed round in September 2024.',
        options: [
          'True',
          'False, it raised \$52M',
          'False, it raised \$520K',
          'False, it has never raised funding',
        ],
        answer: 0,
        explainer: 'True. The \$5.2M seed round closed in September 2024.',
      ),
      QuizQuestion(
        question: 'Fermah was founded by Dr. Vanishree Rao.',
        options: [
          'True',
          'False, it was founded by Vitalik Buterin',
          'False, it was founded by a16z',
          'False, the founder is anonymous',
        ],
        answer: 0,
        explainer: 'True. Dr. Vanishree Rao founded Fermah.',
      ),
      QuizQuestion(
        question: 'Fermah supports only Groth16 proofs.',
        options: [
          'False, it supports all proof systems',
          'True',
          'False, it supports only zkEVMs',
          'False, it supports no proof systems yet',
        ],
        answer: 0,
        explainer:
            'False. Fermah supports all proof systems, including zkVMs, zkEVMs and Groth16.',
      ),
      QuizQuestion(
        question: 'ULTRAMINT is live on Base.',
        options: [
          'True',
          'False, it is live on Solana',
          'False, it is still in stealth',
          'False, it runs on Stellar',
        ],
        answer: 0,
        explainer: 'True. ULTRAMINT is live on Base.',
      ),
      QuizQuestion(
        question: 'Fermah has confirmed a token launch date.',
        options: [
          'False, no token has been confirmed',
          'True, the token launches next month',
          'False, the token already launched',
          'True, the token is called FERM',
        ],
        answer: 0,
        explainer:
            'False. No token has been confirmed, so never trust anyone promising one.',
      ),
      QuizQuestion(
        question: 'Fermah is headquartered in New York.',
        options: [
          'True',
          'False, it is based in London',
          'False, it is fully remote with no HQ',
          'False, it is based in Singapore',
        ],
        answer: 0,
        explainer: 'True. Fermah is headquartered in New York.',
      ),
      QuizQuestion(
        question: 'Kernel locks the rules of a market after the first trade.',
        options: [
          'False, the rules are locked before the first trade',
          'True',
          'False, the rules are never locked',
          'False, the rules change every week',
        ],
        answer: 0,
        explainer: 'False. The rules are locked before the first trade.',
      ),
    ],
  ),
  Quiz(
    id: 'community',
    title: 'Fermafia Community',
    tag: 'The people',
    desc: 'Discord roles, greetings, voice chats and the team.',
    questions: [
      QuizQuestion(
        question: 'What greeting do Fermah community members use?',
        options: ['gFermah', 'gm Fermah', 'Hello ZK', 'WAGMI'],
        answer: 0,
        explainer: 'gFermah is the community greeting in the Discord.',
      ),
      QuizQuestion(
        question: 'Which Discord role comes with the Pioneer NFT?',
        options: ['Pioneer', 'OG', 'Contributor', 'Beta Tester'],
        answer: 0,
        explainer: 'Minting the Pioneer NFT earns the Pioneer role in Discord.',
      ),
      QuizQuestion(
        question: 'What do members call the Fermah community?',
        options: ['Fermafia', 'Fermah Fam', 'ZK Squad', 'Proof Gang'],
        answer: 0,
        explainer: 'The community calls itself the Fermafia.',
      ),
      QuizQuestion(
        question: 'Which voice channel do members hang out in?',
        options: ['CoffeeLounge', 'Proof Pit', 'Moon Room', 'ZK Stage'],
        answer: 0,
        explainer: 'Members hang out in the CoffeeLounge voice channel.',
      ),
      QuizQuestion(
        question: 'Which role marks the most dedicated long-term contributors?',
        options: ['OG', 'Newcomer', 'Beta Tester', 'Guest'],
        answer: 0,
        explainer:
            'OG is earned by the most consistent long-term contributors.',
      ),
      QuizQuestion(
        question: 'Who is 7wealthh in the Fermah community?',
        options: [
          'A team member',
          'A community bot',
          'A rival project founder',
          'An exchange listing manager',
        ],
        answer: 0,
        explainer: '7wealthh is a member of the Fermah team.',
      ),
    ],
  ),
];

/// Mini game word lists, reused from the HTML version.
const List<String> pairsTerms = [
  'KERNEL',
  'PROVER',
  'ULTRAMINT',
  'FROBEN',
  'MATCHMAKER',
  'MOON MATH',
  'GPU',
  'SEEKER',
];

const List<String> rushWords = [
  'KERNEL',
  'PROVER',
  'ULTRAMINT',
  'FROBEN',
  'SEEKER',
  'STELLAR',
  'GROTH16',
  'ZKVM',
  'BASE',
  'GPU',
];

class ScrambleWord {
  const ScrambleWord(this.word, this.hint);
  final String word;
  final String hint;
}

const List<ScrambleWord> scrambleWords = [
  ScrambleWord('KERNEL', 'The engine everything Fermah runs is built on.'),
  ScrambleWord('PROVER', 'The machine or party that generates a ZK proof.'),
  ScrambleWord('ULTRAMINT', 'Mint the market, earn the cut. Live on Base.'),
  ScrambleWord(
      'MATCHMAKER', 'It routes each ZK workload to the right compute.'),
  ScrambleWord('FROBEN', 'The ZK proof market. Any proof system, any chain.'),
  ScrambleWord('STELLAR', 'Fermah Pay runs on this chain.'),
  ScrambleWord('GROTH16', 'A widely used ZK proof system.'),
  ScrambleWord('SEEKER', 'A project that needs a ZK proof generated.'),
];

/// Learn Fermah cards.
class LearnCard {
  const LearnCard(this.title, this.text);
  final String title;
  final String text;
}

const List<LearnCard> learnCards = [
  LearnCard(
    'Seekers',
    'Projects and networks that need a ZK proof generated. They bring the demand to the marketplace.',
  ),
  LearnCard(
    'Matchmaker',
    'The smart router that matches each proof workload with the right compute, so proofs stay cheap, fast and reliable.',
  ),
  LearnCard(
    'Operators',
    'People who run the GPUs and FPGAs that generate proofs. They supply the compute on the marketplace.',
  ),
  LearnCard(
    'Kernel',
    'The engine everything Fermah runs is built on. You write the rule, Kernel runs it and settles onchain.',
  ),
  LearnCard(
    'ULTRAMINT',
    'The first app on Fermah Protocol, live on Base. Mint and trade markets, finish quests and earn USDC bonus credits.',
  ),
  LearnCard(
    'Froben',
    'The ZK proof market. Any proof system, any chain, with proofs generated on demand.',
  ),
  LearnCard(
    'Fermah Pay',
    'Prepaid billing for agent commerce, on Stellar. Deposit once, spend per request.',
  ),
];
