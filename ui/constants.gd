class_name UIConstants

const m_color: Color = Color(0.78125, 0.536413, 0.189944)
const f_color: Color = Color(0.068215, 0.481706, 0.921875)
const player_color: Color = Color(1, 0.3825, 0.24)
const angry_color: Color = Color(1, 0, 0)

static func gender_color(gender:int) -> Color:
	if gender == NPC.M:
		return m_color
	else:
		return f_color

