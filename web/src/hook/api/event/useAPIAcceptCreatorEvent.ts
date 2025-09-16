import { useMutation } from "react-query";
import { axiosInstance } from "@/utils/url";
import { AxiosError } from "axios";
import { jsonHeader } from "@/utils/url/header";
import { UseMutationOptions } from "react-query";

const acceptCreatorEvent = async (creatorEventId: number): Promise<void> => {
  const headers = await jsonHeader;
  await axiosInstance.patch(`/event/creator-event/${creatorEventId}/accept`, {
    headers,
  });
};

export const useAPIAcceptCreatorEvent = (
  mutationOptions?: UseMutationOptions<void, AxiosError, number>
) => {
  return useMutation<void, AxiosError, number>(
    acceptCreatorEvent,
    mutationOptions
  );
};
