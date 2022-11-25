import { combineReducers } from "redux";
import { account_reducer } from "./account_reducer";
import {
  donations_reducer,
  approved_pools_reducer,
  total_funds_reducer,
  completed_pools_reducer,
} from "./stats_reducer";

export const reducers = combineReducers({
  account: account_reducer,
  donations: donations_reducer,
  approved_pools: approved_pools_reducer,
  total_funds: total_funds_reducer,
  completed_pools: completed_pools_reducer,
});
