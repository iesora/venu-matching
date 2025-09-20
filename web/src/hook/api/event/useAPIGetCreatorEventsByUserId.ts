import { useQuery } from "react-query";
import { axiosInstance } from "@/utils/url";
import { CreatorEvent } from "@/type";
import { AxiosError } from "axios";

// イベント参加依頼取得API
const getCreatorEventsByUserId = async (
  userId: number
): Promise<CreatorEvent[]> => {
  const response = await axiosInstance.get(`/event/creator-event/${userId}`);
  console.log(response.data);
  return response.data;
};

// イベント参加依頼取得用hook
export const useAPIGetCreatorEventsByUserId = (userId: number | undefined) => {
  return useQuery<CreatorEvent[], AxiosError>(
    ["getCreatorEventsByUserId", userId],
    () => {
      if (userId === undefined) throw new Error("userIdが未指定です");
      return getCreatorEventsByUserId(userId);
    },
    {
      enabled: userId !== undefined,
    }
  );
};
