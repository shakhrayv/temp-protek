//
//  SearchViewController.m
//  MedsAI
//
//  Created by whoami on 3/17/18.
//  Copyright © 2018 Mountain Viewer. All rights reserved.
//

#import "SearchViewController.h"
#import "SWRevealViewController.h"
#import "ListTableViewCell.h"
//#import "LCStarRatingView.h"

@interface SearchViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *scontrol;

@property (nonatomic, strong) NSArray<NSString *> *prices;
@property (nonatomic, strong) NSArray<NSString *> *names;
@property (nonatomic, strong) NSArray<NSString *> *images;
@property (nonatomic, strong) NSArray<NSString *> *descriptions;
@property (nonatomic, strong) NSArray<NSString *> *manufacturers;
@property (nonatomic, strong) NSArray<NSString *> *compounds;
@property (nonatomic, strong) NSArray<NSString *> *sideEffects;
@property (nonatomic, strong) NSArray<NSString *> *contrs; //Противопоказания
@property int defaultIndex2;

@property (nonatomic, strong) NSString *pushName;
@property (nonatomic, strong) NSString *pushImageName;
@property (nonatomic, strong) NSString *pushDesc;
@property (nonatomic, strong) NSString *pushProducer;
@property (nonatomic, strong) NSString *pushCompound;
@property (nonatomic, strong) NSString *pushSideEffect;
@property (nonatomic, strong) NSString *pushContr;
@property (nonatomic) NSInteger currentIndex;

@property (nonatomic) NSInteger index;

@end

@implementation SearchViewController


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.prices count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Selected %i", indexPath.row);
    self.pushName = self.names[indexPath.row];
    self.pushImageName = self.images[indexPath.row];
    self.pushDesc = self.descriptions[indexPath.row];
    self.pushProducer = self.manufacturers[indexPath.row];
    self.pushCompound = self.compounds[indexPath.row];
    self.pushSideEffect = self.sideEffects[indexPath.row];
    self.pushContr = self.contrs[indexPath.row];
    self.currentIndex = indexPath.row;
    
    [self performSegueWithIdentifier:@"description" sender:self];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"description"]) {
        DescriptionViewController *vc = segue.destinationViewController;
        
        vc.name = self.pushName;
        vc.imageName = self.pushImageName;
        NSLog(@"%@", self.pushImageName);
        vc.desc = self.pushDesc;
        vc.producer = self.pushProducer;
        vc.compound = self.pushCompound;
        vc.sideEffect = self.pushSideEffect;
        vc.contr = self.pushContr;
        vc.rating = [NSString stringWithFormat:@"%ld%%", 100 - 100 * self.currentIndex / self.names.count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    ListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.number.text = [NSString stringWithFormat:@"%ld.", indexPath.row + 1];
    cell.title.text = self.names[indexPath.row];
    cell.producer.text = self.manufacturers[indexPath.row];
    cell.price.text = [NSString stringWithFormat:@"%@р.", self.prices[indexPath.row]];
    cell.imageName = self.images[indexPath.row];
    cell.image.image = [UIImage imageNamed:cell.imageName];
    cell.starImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"%ld", 5 - 3 * indexPath.row / self.names.count]];
    // cell.ratingView.progress = 3;
    //cell.ratingView.backgroundColor = [UIColor whiteColor];
    
    return cell;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.index = [self submitQuery:self.searchBar.text];
    [self.tableView reloadData];
    [self.searchBar resignFirstResponder];
}

- (void)configureRevealVC {
    SWRevealViewController *revealViewController = self.revealViewController;
    
    if (revealViewController) {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector(revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureRevealVC];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchBar.delegate = self;
    
    self.index = [self submitQuery:@""];
    [_scontrol addTarget:self action:@selector(mkSorted:) forControlEvents:UIControlEventValueChanged];
    
    [SVProgressHUD show];
    [SVProgressHUD dismissWithDelay:0.5];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (NSInteger)submitQuery:(NSString *)string {
    if ([string isEqualToString:@""]) {
        int defaultIndex=4;
        self.names = [self getNames:defaultIndex];
        self.images = [self getImages:defaultIndex];
        self.prices = [self getPrices:defaultIndex];
        self.descriptions = [self getDescriptions:defaultIndex];
        self.contrs = [self getContraindicators:defaultIndex];
        self.compounds = [self getCompounds:defaultIndex];
        self.sideEffects = [self getSideEffects:defaultIndex];
        self.manufacturers = [self getManufacturers:defaultIndex];
        return defaultIndex;
    }
    NSString* lowercase = [string lowercaseString];
    
    NSArray<NSString*>* initials = @[@"Ибупрофен", @"Метамизол Натрия", @"Бифидобактерии", @"Парацетамол", @"Амброксол"];
    int defaultIndex = -1;
    bool found = false;
    for (int i = 0; i < 5; i++) {
        if ([initials[i].lowercaseString containsString:lowercase]) {
            defaultIndex = i;
            break;
        }
        for (int j = 0; j < [self getNames:i].count; j++) {
            if ([[self getNames:i][j].lowercaseString containsString:lowercase]) {
                found = true;
                defaultIndex = i;
                break;
            }
        }
        if (found) {
            break;
        }
    }
    if (!found) {
        found = true;
        defaultIndex = 0;
    }
    if (found) {
        _defaultIndex2 = defaultIndex;
        self.names = [self getNames:defaultIndex];
        self.images = [self getImages:defaultIndex];
        self.prices = [self getPrices:defaultIndex];
        self.descriptions = [self getDescriptions:defaultIndex];
        self.contrs = [self getContraindicators:defaultIndex];
        self.compounds = [self getCompounds:defaultIndex];
        self.sideEffects = [self getSideEffects:defaultIndex];
        self.manufacturers = [self getManufacturers:defaultIndex];
        return defaultIndex;
    } else {
        return -1;
    }
}

- (NSArray<NSString *> *)getPrices:(int)idx {
    if (idx == 0) return @[@"368", @"57", @"148", @"162", @"100", @"270"];
    if (idx == 1) return @[@"53", @"58", @"78", @"50", @"66", @"91"];
    if (idx == 2) return @[@"560", @"722", @"307", @"542", @"596", @"374"];
    if (idx == 3) return @[@"49", @"19", @"55", @"15", @"79", @"78"];
    if (idx == 4) return @[@"291", @"92", @"386", @"272", @"51", @"260", @"147", @"123", @"188", @"44", @"177", @"122", @"34", @"61", @"21"];
    return NULL;
}

- (NSArray<NSString *> *)getNames:(int)idx {
    if (idx == 0) return @[@"Нурофен экспресс форте", @"Ибупрофен", @"Миг", @"Нурофен Таб", @"Нурофен Форте", @"Нурофен Экспресс"];
    if (idx == 1) return @[@"Анальгин", @"Анальгин", @"Анальгин Ультра", @"Анальгин", @"Анальгин", @"Анальгин"];
    if (idx == 2) return @[@"Линекс Форте", @"Линекс", @"Линекс", @"Линекс Для Детей капли", @"Линекс", @"Линекс"];
    if (idx == 3) return @[@"Цитрамон", @"Парацетамол", @"Цитрамон П", @"Парацетамол", @"Аскофен", @"Цитрамон Ультра"];
    if (idx == 4) return @[@"Амброксол", @"Лазолван", @"Лазолван Макс", @"Амброксол", @"Амбробене", @"Амбробене ", @"Амбробене ", @"Амбробене ", @"Амброксол", @"Амбробене", @"Амбробене ", @"Амброксол ", @"Бронхорус", @"Бронхорус", @"Коделак Бронхо"];
    return NULL;
}

- (NSArray<NSString *> *)getManufacturers:(int) idx {
    if (idx == 0) return @[@"РЕКИТТ БЕНКИЗЕР ХЭЛСКЭР", @"СИНТЕЗ", @"МЕРЛИН ХЕМИ", @"РЕКИТТ БЕНКИЗЕР ХЭЛСКЭР", @"РЕКИТТ БЕНКИЗЕР ХЭЛСКЭР", @"РЕКИТТ БЕНКИЗЕР ХЭЛСКЭР"];
    if (idx == 1) return @[@"Медисорб", @"Фармстандарт", @"Обуленская", @"Борисовский 3Д Медпрепаратов", @"Борисовский 3Д Медпрепаратов", @"Фармстандарт"];
    if (idx == 2) return @[@"SANDOZ", @"SANDOZ", @"SANDOZ", @"SANDOZ", @"SANDOZ", @"SANDOZ"];
    if (idx == 3) return @[@"Медисорб", @"Медисорб", @"Фармстандарт", @"Фармстандарт", @"Фармстандарт", @"Оболенское"];
    if (idx == 4) return @[@"Виал ООО", @"Санофи Россия", @"Санофи Россия", @"Озон ООО", @"Виал ООО", @"Озон ", @"Тева", @"Виал ООО", @"Канонфарма продакшн", @"Меркле гмбх", @"Меркле гмбх", @"Татхимфармпрепараты", @"Синтез", @"Синтез", @"Коделак Бронхо"];
    return NULL;
}

- (NSArray<NSString *> *)getDescriptions:(int) idx {
    if (idx == 0) return @[@"Ибупрофен — лекарственное средство, нестероидный противовоспалительный препарат из группы производных пропионовой кислоты, обладает болеутоляющим и жаропонижающим действием.", @"Ибупрофен — лекарственное средство, нестероидный противовоспалительный препарат из группы производных пропионовой кислоты, обладает болеутоляющим и жаропонижающим действием.", @"Ибупрофен — лекарственное средство, нестероидный противовоспалительный препарат из группы производных пропионовой кислоты, обладает болеутоляющим и жаропонижающим действием.", @"Ибупрофен — лекарственное средство, нестероидный противовоспалительный препарат из группы производных пропионовой кислоты, обладает болеутоляющим и жаропонижающим действием.", @"Ибупрофен — лекарственное средство, нестероидный противовоспалительный препарат из группы производных пропионовой кислоты, обладает болеутоляющим и жаропонижающим действием.", @"Ибупрофен — лекарственное средство, нестероидный противовоспалительный препарат из группы производных пропионовой кислоты, обладает болеутоляющим и жаропонижающим действием."];
    if (idx == 1) return @[@"Анальгин, лекарственный препарат эффективно и быстро устраняющий головную боль, обладает противовоспалительным, анальгезирующим, жаропонижающим действием.", @"Анальгин, лекарственный препарат эффективно и быстро устраняющий головную боль, обладает противовоспалительным, анальгезирующим, жаропонижающим действием.", @"Анальгин, лекарственный препарат эффективно и быстро устраняющий головную боль, обладает противовоспалительным, анальгезирующим, жаропонижающим действием.", @"Анальгин, лекарственный препарат эффективно и быстро устраняющий головную боль, обладает противовоспалительным, анальгезирующим, жаропонижающим действием.", @"Анальгин, лекарственный препарат эффективно и быстро устраняющий головную боль, обладает противовоспалительным, анальгезирующим, жаропонижающим действием.", @"Анальгин, лекарственный препарат эффективно и быстро устраняющий головную боль, обладает противовоспалительным, анальгезирующим, жаропонижающим действием."];
    if (idx == 2) return @[@"Линекс — комбинированный препарат, содержащий 3 разных вида лиофилизированных жизнеспособных молочнокислых бактерий из разных отделов кишечника, которые являются частью нормальной кишечной флоры, поддерживают и регулируют физиологическое равновесие микрофлоры кишечника.", @"Линекс — комбинированный препарат, содержащий 3 разных вида лиофилизированных жизнеспособных молочнокислых бактерий из разных отделов кишечника, которые являются частью нормальной кишечной флоры, поддерживают и регулируют физиологическое равновесие микрофлоры кишечника.", @"Линекс — комбинированный препарат, содержащий 3 разных вида лиофилизированных жизнеспособных молочнокислых бактерий из разных отделов кишечника, которые являются частью нормальной кишечной флоры, поддерживают и регулируют физиологическое равновесие микрофлоры кишечника.", @"Линекс — комбинированный препарат, содержащий 3 разных вида лиофилизированных жизнеспособных молочнокислых бактерий из разных отделов кишечника, которые являются частью нормальной кишечной флоры, поддерживают и регулируют физиологическое равновесие микрофлоры кишечника.", @"Линекс — комбинированный препарат, содержащий 3 разных вида лиофилизированных жизнеспособных молочнокислых бактерий из разных отделов кишечника, которые являются частью нормальной кишечной флоры, поддерживают и регулируют физиологическое равновесие микрофлоры кишечника.", @"Линекс — комбинированный препарат, содержащий 3 разных вида лиофилизированных жизнеспособных молочнокислых бактерий из разных отделов кишечника, которые являются частью нормальной кишечной флоры, поддерживают и регулируют физиологическое равновесие микрофлоры кишечника."];
    if (idx == 3) return @[@"Парацетамо́л (лат. Paracetamolum) — лекарственное средство, анальгетик и антипиретик из группы анилидов, оказывает жаропонижающее действие.", @"Парацетамо́л (лат. Paracetamolum) — лекарственное средство, анальгетик и антипиретик из группы анилидов, оказывает жаропонижающее действие.", @"Парацетамо́л (лат. Paracetamolum) — лекарственное средство, анальгетик и антипиретик из группы анилидов, оказывает жаропонижающее действие.", @"Парацетамо́л (лат. Paracetamolum) — лекарственное средство, анальгетик и антипиретик из группы анилидов, оказывает жаропонижающее действие.", @"Парацетамо́л (лат. Paracetamolum) — лекарственное средство, анальгетик и антипиретик из группы анилидов, оказывает жаропонижающее действие.", @"Парацетамо́л (лат. Paracetamolum) — лекарственное средство, анальгетик и антипиретик из группы анилидов, оказывает жаропонижающее действие."];
    if (idx == 4) return @[@"Отхаркивающее комбинированное средство", @"Муколитическое средство", @"Отхаркивающее, муколитическое средство", @"Муколитический и отхаркивающий препарат", @"Отхаркивающее муколитическое средство", @"Отхаркивающее муколитическое средство", @"Отхаркивающее, муколитическое средство", @"Отхаркивающее муколитическое средство", @"Отхаркивающее комбинированное средство", @"Отхаркивающее муколитическое средство", @"Муколитическое средство", @"Отхаркивающее, муколитическое средство", @"Муколитический и отхаркивающий препарат", @"Муколитический и отхаркивающий препарат", @"Отхаркивающее муколитическое средство"];
    return NULL;
}

- (NSArray<NSString *> *)getCompounds:(int) idx {
    if (idx == 0) return @[@"Ибупрофен – 200 мг; вспомогательные вещества: повидон К-25, магния стеарат, крахмал картофельный", @"Ибупрофен – 200 мг; вспомогательные вещества: повидон К-25, магния стеарат, крахмал картофельный", @"Ибупрофен – 200 мг; вспомогательные вещества: повидон К-25, магния стеарат, крахмал картофельный", @"Ибупрофен – 200 мг; вспомогательные вещества: повидон К-25, магния стеарат, крахмал картофельный", @"Ибупрофен – 200 мг; вспомогательные вещества: повидон К-25, магния стеарат, крахмал картофельный", @"Ибупрофен – 200 мг; вспомогательные вещества: повидон К-25, магния стеарат, крахмал картофельный"];
    if (idx == 1) return @[@"активное вещество: метамизол натрия (анальгин) - 500 мг; вспомогательные вещества: кальция стеарат, сахарная пудра", @"активное вещество: метамизол натрия (анальгин) - 500 мг; вспомогательные вещества: кальция стеарат, сахарная пудра", @"активное вещество: метамизол натрия (анальгин) - 500 мг; вспомогательные вещества: кальция стеарат, сахарная пудра", @"активное вещество: метамизол натрия (анальгин) - 500 мг; вспомогательные вещества: кальция стеарат, сахарная пудра", @"активное вещество: метамизол натрия (анальгин) - 500 мг; вспомогательные вещества: кальция стеарат, сахарная пудра", @"активное вещество: метамизол натрия (анальгин) - 500 мг; вспомогательные вещества: кальция стеарат, сахарная пудра"];
    if (idx == 2) return @[@"Одна капсула препарата Линекс® содержит не менее 1,2x107 живых лиофилизированных молочнокислых бактерий.", @"Одна капсула препарата Линекс® содержит не менее 1,2x107 живых лиофилизированных молочнокислых бактерий.", @"Одна капсула препарата Линекс® содержит не менее 1,2x107 живых лиофилизированных молочнокислых бактерий.", @"Одна капсула препарата Линекс® содержит не менее 1,2x107 живых лиофилизированных молочнокислых бактерий.", @"Одна капсула препарата Линекс® содержит не менее 1,2x107 живых лиофилизированных молочнокислых бактерий.", @"Одна капсула препарата Линекс® содержит не менее 1,2x107 живых лиофилизированных молочнокислых бактерий."];
    if (idx == 3) return @[@"Ацетилсалициловая кислота - 240 мг; Парацетамол - 180 мг; Кофеин - 30 мг; Вспомогательные вещества.", @"Ацетилсалициловая кислота - 240 мг; Парацетамол - 180 мг; Кофеин - 30 мг; Вспомогательные вещества.", @"Ацетилсалициловая кислота - 240 мг; Парацетамол - 180 мг; Кофеин - 30 мг; Вспомогательные вещества.", @"Ацетилсалициловая кислота - 240 мг; Парацетамол - 180 мг; Кофеин - 30 мг; Вспомогательные вещества.", @"Ацетилсалициловая кислота - 240 мг; Парацетамол - 180 мг; Кофеин - 30 мг; Вспомогательные вещества.", @"Ацетилсалициловая кислота - 240 мг; Парацетамол - 180 мг; Кофеин - 30 мг; Вспомогательные вещества."];
    if (idx == 4) return @[@"Амброксола гидрохлорид 7,5 мг. вспомогательные вещества: лимонной кислоты моногидрат 2 мг, натрия гидрофосфата дигидрат 4,35 мг, натрия хлорид 6,22 мг, вода очищенная 98,9705 г", @"Амброксола гидрохлорид 7.5 мг вспомогательные вещества: калия сорбат, хлористоводородная кислота, вода очищенная.", @"Амброксола гидрохлорид 7,5 мг. вспомогательные вещества: лимонной кислоты моногидрат 2 мг, натрия гидрофосфата дигидрат 4,35 мг, натрия хлорид 6,22 мг, вода очищенная 98,9705 г", @"Амброксола гидрохлорид 7.5 мг вспомогательные вещества: калия сорбат, хлористоводородная кислота, вода очищенная.", @"Активные вещества: амброксола гидрохлорид, тринатриевая соль глицирризиновой кислоты, чабреца экстракт жидкий. вспомогательные вещества: метилпарагидроксибензоат, пропилпарагидрокеибензоат", @"Амброксола гидрохлорид 7,5 мг. вспомогательные вещества: лимонной кислоты моногидрат 2 мг, натрия гидрофосфата дигидрат 4,35 мг, натрия хлорид 6,22 мг, вода очищенная 98,9705 г", @"Амброксола гидрохлорид 7,5 мг. вспомогательные вещества: лимонной кислоты моногидрат 2 мг, натрия гидрофосфата дигидрат 4,35 мг, натрия хлорид 6,22 мг, вода очищенная 98,9705 г", @"Активные вещества: амброксола гидрохлорид, тринатриевая соль глицирризиновой кислоты, чабреца экстракт жидкий. вспомогательные вещества: метилпарагидроксибензоат, пропилпарагидрокеибензоат", @"Амброксола гидрохлорид 7.5 мг вспомогательные вещества: калия сорбат, хлористоводородная кислота, вода очищенная.", @"Амброксола гидрохлорид 7,5 мг. вспомогательные вещества: лимонной кислоты моногидрат 2 мг, натрия гидрофосфата дигидрат 4,35 мг, натрия хлорид 6,22 мг, вода очищенная 98,9705 г", @"Амброксола гидрохлорид 7.5 мг вспомогательные вещества: калия сорбат, хлористоводородная кислота, вода очищенная.", @"Активные вещества: амброксола гидрохлорид, тринатриевая соль глицирризиновой кислоты, чабреца экстракт жидкий. вспомогательные вещества: метилпарагидроксибензоат, пропилпарагидрокеибензоат", @"Амброксола гидрохлорид 7.5 мг вспомогательные вещества: калия сорбат, хлористоводородная кислота, вода очищенная.", @"Амброксола гидрохлорид 7.5 мг вспомогательные вещества: калия сорбат, хлористоводородная кислота, вода очищенная.", @"Амброксола гидрохлорид 7,5 мг. вспомогательные вещества: лимонной кислоты моногидрат 2 мг, натрия гидрофосфата дигидрат 4,35 мг, натрия хлорид 6,22 мг, вода очищенная 98,9705 г"];
    return NULL;
}

- (NSArray<NSString *> *)getSideEffects:(int) idx {
    if (idx == 0) return @[@"Нарушения со стороны крови и лимфатической системы. Нарушения со стороны иммунной системы", @"Нарушения со стороны крови и лимфатической системы. Нарушения со стороны иммунной системы", @"Нарушения со стороны крови и лимфатической системы. Нарушения со стороны иммунной системы", @"Нарушения со стороны крови и лимфатической системы. Нарушения со стороны иммунной системы", @"Нарушения со стороны крови и лимфатической системы. Нарушения со стороны иммунной системы", @"Нарушения со стороны крови и лимфатической системы. Нарушения со стороны иммунной системы"];
    if (idx == 1) return @[@"Со стороны мочевыделительной системы: нарушение функции почек, олигурия, анурия, протеинурия, интерстициальный нефрит.", @"Со стороны мочевыделительной системы: нарушение функции почек, олигурия, анурия, протеинурия, интерстициальный нефрит.", @"Со стороны мочевыделительной системы: нарушение функции почек, олигурия, анурия, протеинурия, интерстициальный нефрит.", @"Со стороны мочевыделительной системы: нарушение функции почек, олигурия, анурия, протеинурия, интерстициальный нефрит.", @"Со стороны мочевыделительной системы: нарушение функции почек, олигурия, анурия, протеинурия, интерстициальный нефрит.", @"Со стороны мочевыделительной системы: нарушение функции почек, олигурия, анурия, протеинурия, интерстициальный нефрит."];
    if (idx == 2) return @[@"Сообщений о нежелательных эффектах нет.", @"Сообщений о нежелательных эффектах нет.", @"Сообщений о нежелательных эффектах нет.", @"Сообщений о нежелательных эффектах нет.", @"Сообщений о нежелательных эффектах нет.", @"Сообщений о нежелательных эффектах нет."];
    if (idx == 3) return @[@"Со стороны пищеварительного тракта,со стороны системы кроветворения, со стороны выделительной системы.", @"Со стороны пищеварительного тракта,со стороны системы кроветворения, со стороны выделительной системы.", @"Со стороны пищеварительного тракта,со стороны системы кроветворения, со стороны выделительной системы.", @"Со стороны пищеварительного тракта,со стороны системы кроветворения, со стороны выделительной системы.", @"Со стороны пищеварительного тракта,со стороны системы кроветворения, со стороны выделительной системы.", @"Со стороны пищеварительного тракта,со стороны системы кроветворения, со стороны выделительной системы."];
    if (idx == 4) return @[@"Аллергические реакции. редко - слабость, головная боль, диарея, сухость во рту и дыхательных путях, запор, дизурия", @"Изредка могут развиваться слабость, головная боль, сухость во рту и дыхательных путях, слюнотечение, гастралгия, тошнота, рвота, диарея, запор, дизурия, экзантема", @"Часто – тошнота нечасто - изжога, диспепсия, рвота, диарея, боли в верхней части живота расстройства иммунной системы, поражения кожи и подкожных тканей", @"Со стороны пищеварительной системы, аллергические реакции", @"Редко - аллергические реакции, лихорадка, слабость, головная боль", @"Редко - аллергические реакции, лихорадка, слабость, головная боль", @"Часто – тошнота нечасто - изжога, диспепсия, рвота, диарея, боли в верхней части живота расстройства иммунной системы, поражения кожи и подкожных тканей", @"Редко - аллергические реакции, лихорадка, слабость, головная боль", @"Аллергические реакции. редко - слабость, головная боль, диарея, сухость во рту и дыхательных путях, запор, дизурия", @"Редко - аллергические реакции, лихорадка, слабость, головная боль", @"Изредка могут развиваться слабость, головная боль, сухость во рту и дыхательных путях, слюнотечение, гастралгия, тошнота, рвота, диарея, запор, дизурия, экзантема", @"Часто – тошнота нечасто - изжога, диспепсия, рвота, диарея, боли в верхней части живота расстройства иммунной системы, поражения кожи и подкожных тканей", @"Со стороны пищеварительной системы, аллергические реакции", @"Со стороны пищеварительной системы, аллергические реакции", @"Редко - аллергические реакции, лихорадка, слабость, головная боль"];
    return NULL;
}

// Противопоказания
- (NSArray<NSString *> *)getContraindicators:(int) idx {
    if (idx == 0) return @[@"Эрозивно-язвенные поражения ЖКТ в фазе обострения, гемофилия, почечная недостаточность тяжелой степени", @"Эрозивно-язвенные поражения ЖКТ в фазе обострения, гемофилия, почечная недостаточность тяжелой степени", @"Эрозивно-язвенные поражения ЖКТ в фазе обострения, гемофилия, почечная недостаточность тяжелой степени", @"Эрозивно-язвенные поражения ЖКТ в фазе обострения, гемофилия, почечная недостаточность тяжелой степени", @"Эрозивно-язвенные поражения ЖКТ в фазе обострения, гемофилия, почечная недостаточность тяжелой степени", @"Эрозивно-язвенные поражения ЖКТ в фазе обострения, гемофилия, почечная недостаточность тяжелой степени"];
    if (idx == 1) return @[@"Гиперчувствительность, угнетение кроветворения,печеночная и/или почечная недостаточность, наследственная гемолитическая", @"Гиперчувствительность, угнетение кроветворения,печеночная и/или почечная недостаточность, наследственная гемолитическая", @"Гиперчувствительность, угнетение кроветворения,печеночная и/или почечная недостаточность, наследственная гемолитическая", @"Гиперчувствительность, угнетение кроветворения,печеночная и/или почечная недостаточность, наследственная гемолитическая", @"Гиперчувствительность, угнетение кроветворения,печеночная и/или почечная недостаточность, наследственная гемолитическая", @"Гиперчувствительность, угнетение кроветворения,печеночная и/или почечная недостаточность, наследственная гемолитическая"];
    if (idx == 2) return @[@"Гиперчувствительность к компонентам препарата,наследственная непереносимость фруктозы.", @"Гиперчувствительность к компонентам препарата,наследственная непереносимость фруктозы.", @"Гиперчувствительность к компонентам препарата,наследственная непереносимость фруктозы.", @"Гиперчувствительность к компонентам препарата,наследственная непереносимость фруктозы.", @"Гиперчувствительность к компонентам препарата,наследственная непереносимость фруктозы.", @"Гиперчувствительность к компонентам препарата,наследственная непереносимость фруктозы."];
    if (idx == 3) return @[@"Повышенная чувствительность к парацетамолу, выраженные нарушения функции печени и почек.", @"Повышенная чувствительность к парацетамолу, выраженные нарушения функции печени и почек.", @"Повышенная чувствительность к парацетамолу, выраженные нарушения функции печени и почек.", @"Повышенная чувствительность к парацетамолу, выраженные нарушения функции печени и почек.", @"Повышенная чувствительность к парацетамолу, выраженные нарушения функции печени и почек.", @"Повышенная чувствительность к парацетамолу, выраженные нарушения функции печени и почек."];
    if (idx == 4) return @[@"Беременность,период лактации,детский возраст до 2 лет, повышенная чувствительность к компонентам препарата", @"Язвенная болезнь желудка и двенадцатиперстной кишки,эпилептический синдром, дети в возрасте до 6 лет, повышенная чувствительность к компонентам препарата.", @"Беременность и период лактации", @"Повышенная чувствительность к компонентам препарата, i триместр беременности, детский возраст до 12 лет", @"Повышенная чувствительность к амброксолу или к одному из вспомогательных веществ, беременность (i триместр),применение у детей до 12 лет.", @"Повышенная чувствительность к амброксолу или к одному из вспомогательных веществ, беременность (i триместр),применение у детей до 12 лет.", @"Беременность и период лактации", @"Повышенная чувствительность к амброксолу или к одному из вспомогательных веществ, беременность (i триместр),применение у детей до 12 лет.", @"Беременность,период лактации,детский возраст до 2 лет, повышенная чувствительность к компонентам препарата", @"Повышенная чувствительность к амброксолу или к одному из вспомогательных веществ, беременность (i триместр),применение у детей до 12 лет.", @"Язвенная болезнь желудка и двенадцатиперстной кишки,эпилептический синдром, дети в возрасте до 6 лет, повышенная чувствительность к компонентам препарата.", @"Беременность и период лактации", @"Повышенная чувствительность к компонентам препарата, i триместр беременности, детский возраст до 12 лет", @"Повышенная чувствительность к компонентам препарата, i триместр беременности, детский возраст до 12 лет", @"Повышенная чувствительность к амброксолу или к одному из вспомогательных веществ, беременность (i триместр),применение у детей до 12 лет."];
    return NULL;
}

- (NSArray<NSString *> *)getImages:(int) idx {
    if (idx == 0) return @[@"image0_0", @"image0_1", @"image0_2", @"image0_3", @"image0_4", @"image0_5"];
    if (idx == 1) return @[@"image1_0", @"image1_1", @"image1_2", @"image1_3", @"image1_4", @"image1_5"];
    if (idx == 2) return @[@"image2_0", @"image2_1", @"image2_2", @"image2_3", @"image2_4", @"image2_5"];
    if (idx == 3) return @[@"image3_0", @"image3_1", @"image3_2", @"image3_3", @"image3_4", @"image3_5"];
    if (idx == 4) return @[@"image4_0", @"image4_1", @"image4_2", @"image4_3", @"image4_4", @"image4_5", @"image4_6", @"image4_7", @"image4_8", @"image4_9", @"image4_10", @"image4_11", @"image4_12", @"image4_13", @"image4_14"];
    return NULL;
}

- (void) mkSorted:(UISegmentedControl*) sender {
    if (sender.selectedSegmentIndex) {
    self.names = [self sortArr:self.names byEtalon:self.prices];
    self.images = [self sortArr:self.images byEtalon:self.prices];
    self.descriptions = [self sortArr:self.descriptions byEtalon:self.prices];
    self.contrs = [self sortArr:self.contrs byEtalon:self.prices];
    self.compounds = [self sortArr:self.compounds byEtalon:self.prices];
    self.sideEffects = [self sortArr:self.sideEffects byEtalon:self.prices];
    self.manufacturers = [self sortArr:self.manufacturers byEtalon:self.prices];
    self.names = [self sortArr:self.names byEtalon:self.prices];
    self.prices = [self sortArr:self.prices byEtalon:self.prices];

    [self.tableView reloadData];
    } else {
        self.names = [self getNames:_defaultIndex2];
        self.images = [self getImages:_defaultIndex2];
        self.prices = [self getPrices:_defaultIndex2];
        self.descriptions = [self getDescriptions:_defaultIndex2];
        self.contrs = [self getContraindicators:_defaultIndex2];
        self.compounds = [self getCompounds:_defaultIndex2];
        self.sideEffects = [self getSideEffects:_defaultIndex2];
        self.manufacturers = [self getManufacturers:_defaultIndex2];
        [self.tableView reloadData];
    }
}

- (NSArray<NSString*>*) sortArr: (NSArray<NSString*>*) arr byEtalon: (NSArray<NSString*>*) prices {
    NSMutableArray<NSNumber*>* n = [[NSMutableArray alloc] init];
    int sz = prices.count;
    for (int i = 0; i < sz; i++) {
        [n addObject: [NSNumber numberWithInt:[prices[i] intValue]]];
    }
    NSMutableArray<NSNumber*>*  n2 = [n mutableCopy];
    [n sortUsingComparator:^(NSNumber* obj1, NSNumber* obj2) {
        if (obj1.intValue > obj2.intValue)
            return NSOrderedAscending;
        else if (obj1.intValue < obj2.intValue)
            return NSOrderedDescending;
        return NSOrderedSame;
    }];
    NSMutableArray<NSString*>* result = [[NSMutableArray alloc] init];
    for (int i = 0; i < sz; i++) {
        int index = -1;
        int price = n[i].intValue;
        for (int j = 0; j < sz; j++) {
            if (price == n2[j].intValue) {
                index = j;
                break;
            }
        }
        [result addObject:arr[index]];
    }
    return result;
}


@end
