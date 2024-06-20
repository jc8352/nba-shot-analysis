library(dplyr)
library(ggplot2)
library(tidyr)
library(shiny)



#find most efficient shots by action type
sort_action_efficieny <- function(shots_22_23) {
  action_types <- shots_22_23 %>% group_by(ACTION_TYPE) %>% summarize(count=n())
  action_type_efficiency <- shots_22_23 %>% group_by(ACTION_TYPE) %>% summarize(pct = sum(SHOT_MADE_FLAG)/sum(SHOT_ATTEMPTED_FLAG), pts_per_shot = (2*sum(SHOT_MADE_FLAG)+sum(SHOT_ZONE_RANGE=="24+ ft." & SHOT_MADE_FLAG))/sum(SHOT_ATTEMPTED_FLAG), n=sum(SHOT_ATTEMPTED_FLAG))                                       
  efficient_shots <- action_type_efficiency[order(action_type_efficiency$pts_per_shot, decreasing=TRUE),]
  return(efficient_shots)
}


#find most efficient players on each action
efficient_players_action <- function(shots_22_23) {
  actions_types_players <- shots_22_23 %>% group_by(ACTION_TYPE, SHOT_TYPE, PLAYER_NAME) %>% summarize(pct = sum(SHOT_MADE_FLAG)/sum(SHOT_ATTEMPTED_FLAG), pts_per_shot = (2*sum(SHOT_MADE_FLAG)+sum(SHOT_ZONE_RANGE=="24+ ft." & SHOT_MADE_FLAG))/sum(SHOT_ATTEMPTED_FLAG), n=sum(SHOT_ATTEMPTED_FLAG))
  most_efficient <- actions_types_players %>% group_by(ACTION_TYPE, SHOT_TYPE) %>% filter(n>20) %>% filter(pts_per_shot==max(pts_per_shot)) %>% summarize(points_per_shot = max(pts_per_shot), top_players=paste(PLAYER_NAME, collapse=","), n=paste(n, collapse=","))
  return(most_efficient)
}

table_efficient_players_action <- function(shots, action, min_shots) {
  actions_types_players <- shots %>% filter(ACTION_TYPE==action) %>% group_by(SHOT_TYPE, PLAYER_NAME) %>% summarize(pct = sum(SHOT_MADE_FLAG)/sum(SHOT_ATTEMPTED_FLAG), pts_per_shot = (2*sum(SHOT_MADE_FLAG)+sum(SHOT_TYPE=="3PT Field Goal" & SHOT_MADE_FLAG))/sum(SHOT_ATTEMPTED_FLAG), n=sum(SHOT_ATTEMPTED_FLAG))
  actions_types_players <- actions_types_players %>% filter(n >= min_shots)
  actions_types_players <- actions_types_players[order(actions_types_players$pts_per_shot, decreasing=TRUE),]
  return(actions_types_players)
}

#find most efficient teams on each action
efficient_teams_action <- function(shots_22_23) {
  actions_types_teams <- shots_22_23 %>% group_by(ACTION_TYPE, SHOT_TYPE, TEAM_NAME) %>% summarize(pct = sum(SHOT_MADE_FLAG)/sum(SHOT_ATTEMPTED_FLAG), pts_per_shot = (2*sum(SHOT_MADE_FLAG)+sum(SHOT_ZONE_RANGE=="24+ ft." & SHOT_MADE_FLAG))/sum(SHOT_ATTEMPTED_FLAG), n=sum(SHOT_ATTEMPTED_FLAG))
  most_efficient <- actions_types_teams %>% group_by(ACTION_TYPE, SHOT_TYPE) %>% filter(pts_per_shot==max(pts_per_shot)) %>% summarize(points_per_shot = max(pts_per_shot), top_teams=paste(TEAM_NAME, collapse=","), n=paste(n, collapse=","))
  return(most_efficient)
}

table_efficient_teams_action <- function(shots, action, min_shots) {
  actions_types_teams <- shots %>% filter(ACTION_TYPE==action) %>% group_by(SHOT_TYPE, TEAM_NAME) %>% summarize(pct = sum(SHOT_MADE_FLAG)/sum(SHOT_ATTEMPTED_FLAG), pts_per_shot = (2*sum(SHOT_MADE_FLAG)+sum(SHOT_TYPE=="3PT Field Goal" & SHOT_MADE_FLAG))/sum(SHOT_ATTEMPTED_FLAG), n=sum(SHOT_ATTEMPTED_FLAG))
  actions_types_teams <- actions_types_teams %>% filter(n >= min_shots)
  actions_types_teams <- actions_types_teams[order(actions_types_teams$pts_per_shot, decreasing=TRUE),]
  return(actions_types_teams)
}

#find most efficient players from each distance
efficient_players_distance <- function(shots_22_23) {
  distances_players <- shots_22_23 %>% group_by(SHOT_DISTANCE, PLAYER_NAME) %>% summarize(pct = sum(SHOT_MADE_FLAG)/sum(SHOT_ATTEMPTED_FLAG), pts_per_shot = (2*sum(SHOT_MADE_FLAG)+sum(SHOT_TYPE=="3PT Field Goal" & SHOT_MADE_FLAG))/sum(SHOT_ATTEMPTED_FLAG), n=sum(SHOT_ATTEMPTED_FLAG))
  most_efficient_distance <- distances_players %>% group_by(SHOT_DISTANCE) %>% filter(n>20) %>% filter(pts_per_shot==max(pts_per_shot)) %>% summarize(points_per_shot=max(pts_per_shot), top_players=paste(PLAYER_NAME, collapse=","), n=paste(n, collapse=","))
  return(most_efficient_distance)
}

#find most efficient teams from each distance
efficient_teams_distance <- function(shots_22_23) {
  distances_teams <- shots_22_23 %>% group_by(SHOT_DISTANCE, TEAM_NAME) %>% summarize(pct = sum(SHOT_MADE_FLAG)/sum(SHOT_ATTEMPTED_FLAG), pts_per_shot = (2*sum(SHOT_MADE_FLAG)+sum(SHOT_TYPE=="3PT Field Goal" & SHOT_MADE_FLAG))/sum(SHOT_ATTEMPTED_FLAG), n=sum(SHOT_ATTEMPTED_FLAG))
  most_efficient_distance <- distances_teams %>% group_by(SHOT_DISTANCE) %>% filter(pts_per_shot==max(pts_per_shot)) %>% summarize(points_per_shot=max(pts_per_shot), top_teams=paste(TEAM_NAME, collapse=","), n=paste(n, collapse=","))
  return(most_efficient_distance)
}

#plot efficiency vs distance
plot_efficiency_vs_distance <- function(shots_22_23) {
  efficiency_by_distance <- shots_22_23 %>% group_by(SHOT_DISTANCE) %>% summarize(pct = sum(SHOT_MADE_FLAG)/sum(SHOT_ATTEMPTED_FLAG), pts_per_shot = (2*sum(SHOT_MADE_FLAG)+sum(SHOT_TYPE=="3PT Field Goal" & SHOT_MADE_FLAG))/sum(SHOT_ATTEMPTED_FLAG), n=sum(SHOT_ATTEMPTED_FLAG))
  viz <- ggplot(data=efficiency_by_distance%>%filter(SHOT_DISTANCE<=40), aes(x=SHOT_DISTANCE, y=pts_per_shot))+geom_point()+labs(title="Points per Shot at Each Distance from the Basket", x="Shot Distance", y="Points per Shot")
  viz
}

calculate_z_score <- function(total_shots_made, total_shots_attempted, player_shots_made, player_shots_attempted) {
  # Overall shooting percentage
  overall_shooting_percentage <- total_shots_made / total_shots_attempted
  
  # Player's shooting percentage
  player_shooting_percentage <- player_shots_made / player_shots_attempted
  
  # Standard deviation for the sample (player's shots)
  std_deviation <- sqrt(overall_shooting_percentage * (1 - overall_shooting_percentage) / player_shots_attempted)
  
  # Z-score calculation
  z_score <- (player_shooting_percentage - overall_shooting_percentage) / std_deviation
  
  return(z_score)
}


#group by action type and shot type, find players efficiency compared to average
vs_average <- function(shots) {
  league_averages <- shots %>% group_by(SHOT_DISTANCE) %>% summarize(pct = sum(SHOT_MADE_FLAG)/sum(SHOT_ATTEMPTED_FLAG), pts_per_shot = (2*sum(SHOT_MADE_FLAG)+sum(SHOT_TYPE=="3PT Field Goal" & SHOT_MADE_FLAG))/sum(SHOT_ATTEMPTED_FLAG), n=sum(SHOT_ATTEMPTED_FLAG))
  player_percentages <- shots %>% filter(SHOT_DISTANCE <= 30) %>% group_by(SHOT_DISTANCE, PLAYER_NAME) %>% summarize(pct = sum(SHOT_MADE_FLAG)/sum(SHOT_ATTEMPTED_FLAG), pts_per_shot = (2*sum(SHOT_MADE_FLAG)+sum(SHOT_TYPE=="3PT Field Goal" & SHOT_MADE_FLAG))/sum(SHOT_ATTEMPTED_FLAG), n=sum(SHOT_ATTEMPTED_FLAG))
  player_vs_league <- inner_join(league_averages, player_percentages, by=c('SHOT_DISTANCE'='SHOT_DISTANCE'), suffix=c('_league', '_player'))
  player_vs_league <- player_vs_league %>% mutate(z = calculate_z_score(pct_league*n_league, n_league, pct_player*n_player, n_player))
  return(player_vs_league)
  
}

#plot z-scores
plot_player_vs_avg <- function(player_vs_league, player) {
  viz <- ggplot(data=player_vs_league%>%filter(PLAYER_NAME==player), aes(x=SHOT_DISTANCE, y=z)) +
    geom_col(just=.5) +
    labs(title="Z-Score of Shooting Percentage from Each Distance", x="Distance from Basket (ft)", y="Z-Score", subtitle="Number of standard deviations above/below league average shooting percentage at each distance from basket")
  viz
}

#plot shot distribution
plot_player_distance_frequencies <- function(shots, player) {
  player_shots <- shots %>% filter(SHOT_DISTANCE <= 30 & PLAYER_NAME==player)
  player_frequencies <- player_shots %>% mutate(distances=cut(SHOT_DISTANCE, breaks=c(-1,3,6,9,12,15,18,21,24,27,30))) %>% group_by(distances) %>% summarize(frequency=sum(SHOT_ATTEMPTED_FLAG)/sum(player_shots$SHOT_ATTEMPTED_FLAG))
  viz <- ggplot(data=player_frequencies, aes(x="",y=frequency, fill=distances)) + 
    geom_bar(stat="identity", width=1, color="black") +
    coord_polar("y", start=0) +
    theme_void() +
    scale_fill_discrete(name= "Distance", labels= c("0-3 ft.", "4-6 ft.", "7-9 ft.", "10-12 ft.", "13-15 ft.", "16-18 ft.", "19-21 ft", "22-24 ft.", "25-27 ft.", "28-30 ft.")) +
    labs(title="Shot Distribution")
  viz
}

#plot shot distribution vs league average
plot_player_vs_league_frequencies <- function(shots, player) {
  player_shots <- shots %>% filter(SHOT_DISTANCE <= 30 & PLAYER_NAME==player)
  player_frequencies <- player_shots %>% mutate(distances=cut(SHOT_DISTANCE, breaks=c(-1,3,6,9,12,15,18,21,24,27,30))) %>% group_by(distances) %>% summarize(frequency=sum(SHOT_ATTEMPTED_FLAG)/sum(player_shots$SHOT_ATTEMPTED_FLAG))
  player_frequencies <- player_frequencies %>% mutate(group=player)
  league_frequencies <- shots %>% filter(SHOT_DISTANCE <= 30) %>% mutate(distances=cut(SHOT_DISTANCE, breaks=c(-1,3,6,9,12,15,18,21,24,27,30))) %>% group_by(distances) %>% summarize(frequency=sum(SHOT_ATTEMPTED_FLAG)/sum(shots$SHOT_ATTEMPTED_FLAG))
  league_frequencies <- league_frequencies %>% mutate(group="League")
  combined_frequencies <- bind_rows(player_frequencies, league_frequencies)
  viz <- ggplot(data=combined_frequencies, aes(fill=group, y=frequency, x=distances)) +
    geom_bar(position="dodge", stat="identity") +
    scale_x_discrete(labels=c("0-3", "4-6", "7-9", "10-12", "13-15", "16-18", "19-21", "22-24", "25-27", "28-30")) +
    labs(x="Distance from Basket (ft)", y="Frequency", fill="", title="Shot Distribution Compared to League Average")
  viz
}



