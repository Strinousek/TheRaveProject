import { useEffect, useState } from "react";
import { StatsInterface } from "../utils/types";
import { fetchNui } from "../utils/fetchNui";
import { delay } from "../utils/misc";

type FetchStatsState = {
  loading: boolean;
  data: StatsInterface;
  error?: string;
};

const DEFAULT_STATE = {
  loading: true,
  data: {
    playedTime: {
        days: 0,
        hours: 0,
        minutes: 0,
        seconds: 0,
    }
  },
  error: undefined,
};

export const useFetchStats = () => {
  const [state, setState] = useState<FetchStatsState>(DEFAULT_STATE);

  useEffect(() => {
    let unmount = false;

    setState(DEFAULT_STATE);

    const fetchData = async () => {
      try {
        /*
          Typescript can't re-type received object from client to Map interface.
          therefore forEach method is not available, because Typescript recognizes received object as object :Nerdge:
        */
        const data = await fetchNui("getStats");

        //ARTIFICIAL DELAY
        await delay(500);

        if (!unmount) {
          setState({ loading: false, data: data });
        }
      } catch (error) {
        if (!unmount) {
          setState({ loading: false, data: DEFAULT_STATE.data, error: "Failed to load stats..." });
        }
      }
    };

    fetchData();

    return () => {
      unmount = true;
    };
  });

  return { ...state };
};