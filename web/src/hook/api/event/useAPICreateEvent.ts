import { useMutation, UseMutationOptions } from "react-query";
import { axiosInstance } from "@/utils/url";
import { Event } from "@/type";
import { AxiosError } from "axios";
import { jsonHeader } from "@/utils/url/header";
import { eventURL } from "@/utils/url/event";

export interface CreateEventRequest {
  title: string;
  description: string;
  startDate: Date;
  endDate: Date;
  venueId: number;
  creatorIds: number[];
}

const createEvent = async (body: CreateEventRequest) => {
  const headers = await jsonHeader;
  const response = await axiosInstance.post(eventURL, body, {
    headers,
  });
  return response.data;
};

export const useAPICreateEvent = (
  mutationOptions?: UseMutationOptions<Event, AxiosError, CreateEventRequest>
) => {
  return useMutation<Event, AxiosError, CreateEventRequest>(
    createEvent,
    mutationOptions
  );
};
