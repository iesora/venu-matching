import { useMutation, UseMutationOptions } from "react-query";
import { axiosInstance } from "@/utils/url";
import { creatorEventURL } from "@/utils/url/event";
import { Event } from "@/type";
import { AxiosError } from "axios";
import { jsonHeader } from "@/utils/url/header";

export interface UpdateCreatorEventRequest {
  eventId: number;
  creatorIds: number[];
}

const updateCreatorEvent = async (body: UpdateCreatorEventRequest) => {
  const headers = await jsonHeader;
  const response = await axiosInstance.patch(creatorEventURL, body, {
    headers,
  });
  return response.data;
};

export const useAPIUpdateCreatorEvent = (
  mutationOptions?: UseMutationOptions<
    Event,
    AxiosError,
    UpdateCreatorEventRequest
  >
) => {
  return useMutation<Event, AxiosError, UpdateCreatorEventRequest>(
    updateCreatorEvent,
    mutationOptions
  );
};
