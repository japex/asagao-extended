module MembersHelper

  def occupation_display(member)
    occupation = member.occupation
    return nil unless occupation
    description = member.occupation_detail.try(:description)
    occupation.category + (occupation.needs_description ? "（#{description}）" : "")
  end
end
