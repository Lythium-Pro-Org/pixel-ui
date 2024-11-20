function PulsarUI.GetRank(ply)
	return ply:GetUserGroup() or ply:GetSecondaryUserGroup()
end
