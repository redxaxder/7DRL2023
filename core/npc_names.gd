class_name NPC_Names

#factions
const austria: String = "Austria"
const britain: String = "Britain"
const russia: String = "Russia"
const prussia: String = "Prussia"
const france: String = "France"

#keys
const faction: String = "faction"
const gender: String = "gender"
const spouse: String = "spouse"
const title: String = "title"
const character: String = "character"

const M: int = 0
const F: int = 1

const name_map: Dictionary = {
	"Klemens von Metternich": {
		faction: austria,
		gender: M,
		spouse: "Eleonore von Kaunitz",
		title: "Prince of Metternich-Winneburg zu Beilstein",
		character: "K"
	},
	"Eleonore von Kaunitz": {
		faction: austria,
		gender: F,
		spouse: "Klemens von Metternich",
		character: "E"
	},
	"Johann Philipp Freiherr von Wessenberg-Ampringen": {
		faction: austria,
		gender: M,
		title: "Minister-President of the Austrian Empire",
		character: "J"
	},
	"Arthur Wellesley": {
		faction: britain,
		gender: M,
		spouse: "Catherine Pakenham",
		title: "Field Marshal His Grace The Duke of Wellington",
		character: "U"
	},
	"Catherine Pakenham": {
		faction: britain,
		gender: F,
		spouse: "Arthur Wellesley",
		character: "C"
	},
	"Tsar Alexander I": {
		faction: russia,
		gender: M,
		spouse: "Elizabeth Alexeievna",
		title: "Emperor of Russia",
		character: "A"
	},
	"Elizabeth Alexeievna": {
		faction: russia,
		gender: F,
		spouse: "Tsar Alexander I",
		title: "Empress consort of Russia",
		character: "L"
	},
	"Karl Nesselrode": {
		faction: russia,
		gender: M,
		spouse: "Maria Guryeva",
		title: "Foreign Minister of the Russian Empire",
		character: "N"
	},
	"Maria Guryeva": {
		faction: russia,
		gender: F,
		spouse: "Karl Nesselrode",
		character: "M"
	},
	"Karl August Furst von Hardenberg": {
		faction: prussia,
		gender: M,
		spouse: "Christiane von Reventlow",
		title: "Prime Minister of Prussia",
		character: "H"
	},
	"Christiane von Reventlow": {
		faction: prussia,
		gender: F,
		spouse: "Karl August Furst von Hardenberg",
		character: "S"
	},
	"Wilhelm von Humboldt": {
		faction: prussia,
		gender: M,
		spouse: "Caroline von Humboldt",
		character: "W"
	},
	"Caroline von Humboldt": {
		faction: prussia,
		gender: F,
		spouse: "Wilhelm von Humboldt",
		character: "O"
	},
	"Friedrich Wilhelm III": {
		faction: prussia,
		gender: M,
		title: "King of Prussia",
		character: "F"
	},
	"Charles Maurice de Talleyrand-Perigord": {
		faction: france,
		gender: M,
		spouse: "Catherine Noel Grand",
		title: "Minister of Foreign Affairs",
		character: "T"
	},
	"Catherine Noel Grand": {
		faction: france,
		gender: F,
		spouse: "Charles Maurice de Talleyrand-Perigord",
		title: "Princesse de Benevent",
		character: "G"
	},
	"Wilhelmine Benigna": {
		faction: austria,
		gender: F,
		title: "Duchess of Sagan",
		character: "B"
	},
	"Catherine Bagration": {
		faction: russia,
		gender: F,
		title: "Princess Bagration",
		character: "I"
	},
#	"": {
#		faction: "",
#		gender: "",
#		spouse: "",
#		title: "",
#		character: ""
#	},
}
